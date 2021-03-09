# Entity Framework and built-in functions

Entity Framework is a great tool, it does a really good job of doing a really difficult task. There are lots of ways to configure how it behaves for the user's needs too. Ok, I'm a fan, enough gushing about it.

There are however times where I despair. Things that on the face of it should be simple and just take a lot longer than you might expect.

Take database functions. There is the means to customise how it works, but with some caveats. Take built in functions.

Entity Framework provides date focused functions, such as `DiffHours` and [some other utility functions](https://docs.microsoft.com/en-us/dotnet/api/system.data.entity.dbfunctions?view=entity-framework-6.2.0) such as Like and Collate. But what about `FORMAT`, `DATEADD`, etc. They're built in functions, but to entity Framework they're inaccessible, in a way.

So there needs to be a way of saying that a built in function exists, so it can be used. In EF 5 there is this ability, but what if you're using an older version?

Remember built in Vs user functions work in different ways. Entity Framework knows how to call them specifically based on their type. So you can't register a built in function as a user function, it won't work. Doing so in some cases results in some very peculiar errors.

So how do you do it... Like this, relatively simple if a bit fugly in before EF 5.

```csharp
class MyDbContext
{
   ...
   public static string DateFormat(DateTime? date, string format) => throw new NotImplentedException();
   ...
   public void OnModelCreating(ModelBuilder modelBuilder)
   {
       modelBuilder
          .HasDbFunction(this.GetType().GetMethod(nameof(DateFormat)))
          .HasTranslation(args => {
              return new SqlFunctionExpression(
                null, /* the method DateFormat is static, no instance is required */
                null, /* built in functions don't have schemas */
                "DATE_FORMAT",
                false, /* this function isnt a niladic function */
                args,
                true, /* this function IS built in*/
                typeof(string), /* this function returns a string*/
                null /* let EF work out the type mapping*/);
          });
   }
   ...
}
```

Now in EF 5 you can simply use the [IsBuiltIn()](https://docs.microsoft.com/en-us/dotnet/api/microsoft.entityframeworkcore.metadata.builders.dbfunctionbuilder.isbuiltin?view=efcore-5.0#Microsoft_EntityFrameworkCore_Metadata_Builders_DbFunctionBuilder_IsBuiltIn_System_Boolean_) method after calling `HasDbFunction`, but if you're not lucky enough to have access to this version then the above works.

Seems simple doesn't it, but when it's not documented at all, and all other documentation states that built in functions are those provided on DbFunctions, it makes it more difficult to see the solution.

Now, why would you want to this I hear you ask. If you simply want to format something, just do that in-memory.

Yes, that would work in normal cases, but doesn't work for the following, at least:

- where you want a query that can join one field to another based on the result of a function. Such as join a date to a string field
- where you want to use the query to produce an insert statement into another (temporary or permanent table)
- where you're using some of the built in free-text functions of the database in the where OR select blocks

Kudos to [Khalid Abuhakmeh](https://khalidabuhakmeh.com/add-custom-database-functions-for-entity-framework-core) which helped diagnose and solve this particular challenge.

See also:
- [SqlFunctionExpression](https://docs.microsoft.com/en-us/dotnet/api/microsoft.entityframeworkcore.query.sqlexpressions.sqlfunctionexpression.-ctor?view=efcore-3.1#Microsoft_EntityFrameworkCore_Query_SqlExpressions_SqlFunctionExpression__ctor_System_Linq_Expressions_Expression_System_String_System_String_System_Boolean_System_Collections_Generic_IEnumerable_Microsoft_EntityFrameworkCore_Query_SqlExpressions_SqlExpression__System_Boolean_System_Type_Microsoft_EntityFrameworkCore_Storage_RelationalTypeMapping_)
