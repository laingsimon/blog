# Run-time deserialisation of different property types

Imagine you have an API, it can take JSON content in a request. Simple.

Now lets make things a little more complicated, you now need to be able to vary the type of one of the object properties based on another property... how do you do it?

So lets presume there is a JSON request to validate the identity of someone. Its a made-up scenario, I've never done anything (to date) with identity verification. Buy I think it can convey the challenge appropriately.

So lets demystify what the request would look like:

```javascript
{ 
    "Submission": { "ProvidedDocument": "Passport" },
    "IdentityDocument": { 
        "PassportNumber": "12345A",
        "PlaceOfBirth": "England" 
    }
}
```

I know [you can specify the type of the document](https://www.newtonsoft.com/json/help/html/SerializationSettings.htm#TypeNameHandling), in the "IdentityDocument" object and get Newtonsoft.JSON to work it out for you. I know you could also have a `PassportProperty` and a `DrivingLicense` property, each only set to an instance if it has been provided. But let's just say for now, this is the input that needs to be used.

So there is a property called "ProvidedDocument" that tells you what type of object "IdentityDocument" is. No compile-time cleverness is going to get you out of jail here, unless you want to use untyped dictionaries or `JObject`s - no thanks.

Lets quickly model the above JSON as C# objects, to remove any ambiguity about what can be written into the API. The following types can represent the above, including two types of identity document - Passport and DrivingLicense.

```csharp
public class IdentityVerificationRequest
{
    public Submission Submission { get; set; }
    public IIdentityDocument IdentityDocument { get; set; }
}

public class Submission
{
    public IdentityDocument ProvidedDocument { get; set; }
}

public enum IdentityDocument
{
    Passport,
    DrivingLicense
}

public interface IIdentityDocument
{
    string UniqueNumber { get; }
}

public class Passport : IIdentityDocument
{
    public string UniqueNumber { get; set; }
    public string PlaceOfBirth { get; set; }
}

public class DrivingLicense : IIdentityDocument
{
    public string UniqueNumber { get; set; }
    public string VehicleClassifications { get; set; }
}
```

Great, we've got some C# types, but how do we deserialise them. We're probably going to need a [JsonConverter](https://www.newtonsoft.com/json/help/html/T_Newtonsoft_Json_JsonConverterAttribute.htm), so lets create one and bind it.

```csharp
[JsonConverter(typeof(IdentityVerificationRequestJsonConverter))]
public class IdentityVerificationRequest
{
    ...
}

public class IdentityVerificationRequestJsonConverter : JsonConverter<IdentityVerificationRequest>
{
    public override IdentityVerificationRequest ReadJson(JsonReader reader, Type objectType, IdentityVerificationRequest existingValue, bool hasExistingValue, JsonSerializer serializer)
    {
        return base.ReadJson(reader, objectType, existingValue, hasExistingValue, serialiser);
    }

    public override void WriteJson(JsonWriter writer, [AllowNull] IdentityVerificationRequest value, JsonSerializer serializer)
    {
        throw new NotImplementedException("Not worrying about serialisation in this post");
    }
}
```

Ok, so now there is a means to customise the way `IdentityVerificationRequest` is deserialised, this is going to be needed somehow, but how.

There is a problem here though, the property `IdentityDocument` cannot be deserialised as it is of an interface type - `IIdentityDocument`. Any attempt to deserialise it will fail with an exception, as the serialiser doesn't know which type of object should be created.

So lets set this property to ignored, we'll setup some custom way of deserialising this property. So the C# model now looks like this:

```csharp
[JsonConverter(typeof(IdentityVerificationRequestJsonConverter))]
public class IdentityVerificationRequest
{
    public Submission Submission { get; set; }

    [JsonIgnore]
    public IIdentityDocument IdentityDocument { get; set; }
}
```

Great, so next steps - we need the content of IdentityDocument, so we can deserialise it ourselves in the converter. We can add a JToken property to capture the content - that should work. But we don't want to pollute the `IdentityVerificationRequest` model with this - so lets put it somewhere else. That said, we don't want to have to maintain two different types. Any property which is added/changed/removed from `IdentityVerificationRequest` should be removed from this new one too. 

Lets use inheritance, that'll do it all for us automatically! So lets create a 'proxy' type, that we'll use in the converter, it could look like this:

```csharp
public class IdentityVerificationRequestJsonConverter
{
    ...

    private class IdentityVerificationRequestProxy : IdentityVerificationRequest
    {
        [JsonProperty(nameof(IdentityDocument))]
        public JToken IdentityDocumentProxy { get; set; }
    }
}
```

To make sure that no-one accidentally uses this class, we've made it a private sub-class of the `JsonConverter`.

This looks promising. If we use this type to deserialise the incoming request - rather than `IdentityVerificationRequest` then we'll get the data for the `IdentityDocument` as a `JToken` in `IdentityDocumentProxy`. At the same time any changes to `IdentityVerificationRequest` will be automatically available to this proxy type.

so we'll change the converters' ReadJson method so it looks like this:

```csharp
public override IdentityVerificationRequest ReadJson(JsonReader reader, Type objectType, IdentityVerificationRequest existingValue, bool hasExistingValue, JsonSerializer serializer)
{
    return serializer.Deserialize<IdentityVerificationRequestProxy>(reader);
}

private class IdentityVerificationRequestProxy : IdentityVerificationRequest
{
    [JsonProperty(nameof(IdentityDocument))]
    public JToken IdentityDocumentProxy { get; set; }
}
```

Lets try it out. Lets use NUnit to test that it works. We'll ignore the content of the `IdentityDocument` property for now, let's simply check that the rest is working without issue. So here we go a simple test:

```csharp
[TestFixture]
public class CustomJsonConverterTest
{
    [Test]
    public void TestConverter()
    {
        var json = @"{ ""Submission"": { ""ProvidedDocument"": ""Passport"" }, ""IdentityDocument"": { ""PassportNumber"": ""12345A"", ""PlaceOfBirth"": ""England"" }}";

        var result = JsonConvert.DeserializeObject<IdentityVerificationRequest>(json);

        Assert.That(result.Submission, Is.Not.Null);
        Assert.That(result.Submission.ProvidedDocument, Is.EqualTo(IdentityDocument.Passport));
    }
}
```

Looks good, but running it throws a `StackOverflowException` 🤯.

When digging into this a bit futher it is because the json serialiser is using our JsonConverter to deserialise the `IdentityVerificationRequestProxy`. This means the call to `serializer.Deserialize<IdentityVerificationRequestProxy>(reader);` calls back into itself. Newtonsoft is detecting this and throwing before a stackoverflow would occur.

Ah, so we don't want our converter to execute when deserialising `IdentityVerificationRequestProxy`, but we do when `IdentityVerificationRequest` is being deserialised. But, as JsonConverters are inherited, so any converter registered on a base class will be seen on any derived class... We need a way to disable or replace the converter with the original.

[Enter stackoverflow](https://stackoverflow.com/a/61515268/774554) and thanks go to [Michael Ireland](https://stackoverflow.com/users/12179122/michael-ireland).

There can only be one `JsonConverter` type registered per type. If one is registered on a type - it replaces any that would have been inherited. So if we create a JsonConverter that prevents custom deserialisation the `JsonSerialiser` will go back to the default way of working. Lets create that converter...

```csharp
public class DisabledJsonConverter : JsonConverter
{
    public override bool CanConvert(Type objectType) => false;
    public override object ReadJson(JsonReader reader, Type objectType, object existingValue, JsonSerializer serializer) 
        => throw new NotSupportedException();
    public override void WriteJson(JsonWriter writer, object value, JsonSerializer serializer) 
        => throw new NotSupportedException();
    public override bool CanRead => false;
    public override bool CanWrite => false;
}
```

And we'll register it on the `IdentityVerificationRequestProxy` class:
```csharp
[JsonConverter(typeof(DisabledJsonConverter))]
public class IdentityVerificationRequestProxy : IdentityVerificationRequest
```

Hmmm, once again - let's prove it works now. Success - we have lift-off. The test passes ✔.

Now we need to get the clever (ish) bit working, the switching between the type of identity document. So we need to go back to our `ReadJson` method in the converter. Here's a reminder of what we have:

```csharp
public override IdentityVerificationRequest ReadJson(JsonReader reader, Type objectType, IdentityVerificationRequest existingValue, bool hasExistingValue, JsonSerializer serializer)
{
    return serializer.Deserialize<IdentityVerificationRequestProxy>(reader);
}
```

So we deserialise the JSON into the proxy. The project has the IdentityDocument property stored as a JToken. Everything else has been deserialised as per normal into the IdentityVerificationProxy type.

Now, I happen to know that there is a `CreateReader()` method on JToken, which means we can create a JsonReader for the contents of the `IdentityDocumentProxy` property. Therefore we can deserailise it, al we need to do is work out which type to deserialise into. Luckily the deserailised version of `IdentityVerificationRequestProxy` has all we need, via the `Submission.ProvidedDocument` property. So lets bring this all together...

```csharp
public override IdentityVerificationRequest ReadJson(JsonReader reader, Type objectType,  IdentityVerificationRequest existingValue, bool hasExistingValue, JsonSerializer serializer)
{
    var request = serializer.Deserialize<IdentityVerificationRequestProxy>(reader);
    request.IdentityDocument = GetIdentityDocument(request.IdentityDocumentProxy, request.Submission?.ProvidedDocument, serializer);
    return request;
}

private IIdentityDocument GetIdentityDocument(JToken objectProxy, IdentityDocument? documentType, JsonSerializer serializer)
{
    if (objectProxy == null || documentType == null)
        return null;

    using (var objectReader = objectProxy.CreateReader())
    {
        switch (documentType)
        {
            case IdentityDocument.Passport:
                return serializer.Deserialize<Passport>(objectReader);
            case IdentityDocument.DrivingLicense:
                return serializer.Deserialize<DrivingLicense>(objectReader);
        }
    }

    return null;
}
```

A bit involved, but not too complicated. Basically it reads out the value from the `Submission.ProvidedDocument` property. It uses this to work out what c# type `IdentityDocument` should be deserialised into, and uses the JToken to deserialise into it. Simples 😉.

Lets wrap it up with an updated unit test, lets also check it does that switching properly, so we'll need to add in at least 2 document types. Here's an updated unit test:

```csharp
[TestFixture]
public class CustomJsonConverterTest
{
    [Test]
    public void TestConverter()
    {
        var json = @"[
{ ""Submission"": { ""ProvidedDocument"": ""Passport"" }, ""IdentityDocument"": { ""PassportNumber"": ""12345A"", ""PlaceOfBirth"": ""England"" }},
{ ""Submission"": { ""ProvidedDocument"": ""DrivingLicense"" }, ""IdentityDocument"": { ""UniqueNumber"": ""ABCD456"", ""VehicleClassifications"": ""A, B2, BE"" }}
]";

        var result = JsonConvert.DeserializeObject<IdentityVerificationRequest[]>(json);

        var firstResult = result.First();
        Assert.That(firstResult.Submission, Is.Not.Null);
        Assert.That(firstResult.IdentityDocument, Is.Not.Null);
        Assert.That(firstResult.Submission.ProvidedDocument, Is.EqualTo(IdentityDocument.Passport));
        Assert.That(firstResult.IdentityDocument.UniqueNumber, Is.EqualTo("12345A"));
        Assert.That(firstResult.IdentityDocument, Is.TypeOf<Passport>());

        var secondResult = result.Last();
        Assert.That(secondResult.Submission, Is.Not.Null);
        Assert.That(secondResult.IdentityDocument, Is.Not.Null);
        Assert.That(secondResult.Submission.ProvidedDocument, Is.EqualTo(IdentityDocument.DrivingLicense));
        Assert.That(secondResult.IdentityDocument.UniqueNumber, Is.EqualTo("ABCD456"));
        Assert.That(secondResult.IdentityDocument, Is.TypeOf<DrivingLicense>());
    }
}
```

Great! Running the tests proves that it all works.