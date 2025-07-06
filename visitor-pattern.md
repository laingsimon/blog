## What is the visitor pattern
To understand the visitor pattern, as with most of [the other design patterns](https://en.m.wikipedia.org/wiki/Software_design_pattern), I find it helps to describe it in real-world terms. To that end imagine you’re a tourist going to visit castles, bear with me, hopefully this will make some sense.

<center style="font-size: 50px">🏰</center>

So you go to a castle, let's say you go to [Corfe castle in Dorset](https://en.wikipedia.org/wiki/Corfe_Castle), and you want to look in the gift shop. Humour me and imagine for the moment that there isn't a map on site or any form of tour guide that can show you around. You have to wander around looking for the gift shop.

So, you wander around Corfe castle and you happen upon the gift shop. Are you allowed to go in? Is it within the opening hours? Are they performing a stock take? The only way to know is to ask a member of staff. They tell you it is open between 9 and 5 on weekdays and you can't go in if you're wearing shorts. So right now, you can go in, but ultimately it's [the castle that permits you](https://en.m.wikipedia.org/wiki/Role-based_access_control) to do so.

Great, you can go to Corfe castle anytime you want and you know whether you can go into the gift shop. You've got cough castle sussed!

Now you want to go to a different castle, let's say [Clitheroe in the north of England](https://en.wikipedia.org/wiki/Clitheroe), and look at their gift shop. But where is it? What are the conditions of entry? The only people who know are those who run Clitheroe castle; you've got to find it all out. You’ve got to start from square one again with this castle. If you go to a another castle, say [Caernarfon castle in North Wales](https://en.m.wikipedia.org/wiki/Caernarfon_Castle), you have to repeat the same steps again. Then each time you, a single tourist, knows where and under what conditions you can enter each gift shop. The next tourist has to learn this out for themselves, from scratch.

**There has to be a better way**

In the real world there are tour guides to help tourists, taking them where they want to go, and only if they're able to. They'll not take you to Caernarfon castle gift shop if it is a Tuesday because they do a stock take then, and they wouldn't allow you into Corfe castle gift shop if you are wearing shorts.

As a result every tourist can be taken to the gift shop, if it is open and if they meet the criteria that each castle has defined. All the customers need to do is look for the tour guide.

There is a cost for every castle though. Each castle has to employ these tour guides. They have to make sure that each tourist is provided a guide as they arrive¹ (the visitor pattern), and they never wander off alone². The castle benefits, they know that customers will only enter the gift shop if they're allowed to. The tourists benefit because they get what they want, instantly, without having to learn the layout of each castle³ (code reuse) or the conditions of gift shop entry⁴ (permissions).

I know for the sake of argument that every castle doesn't have enough tour guides on tap to cover every tourist that comes along. And for completeness, I'm sure the gift shop at each castle IS open at weekends and you CAN actually walk in with shorts on! Also, I have no idea when the shops check their stock either.

This is the essence of the visitor pattern, so what does it look like in code?

```csharp
interface IGiftShopVisitor
{
    void VisitGiftShop(IGiftShop giftShop);
}

class CorfeCastle
{
    private GiftShop m_Shop;

    void Accept(IGiftShopVisitor visitor)
    {
         if (IsGiftShopOpen() == true && IsTouristWearingShorts() == false)
         {
              visitor.VisitGiftShop(m_Shop);
         }
    }
}

class AlwaysBuysAFridgeMagnet : IGiftShopVisitor
{
    void VisitGiftShop(IGiftShop giftShop)
    {
        // Buy a fridge magnet
    }
}

class AlwaysBuysFudge : IGiftShopVisitor
{
    void VisitGiftShop(IGiftShop giftShop)
    {
        // Buy some fudge
    }
}

class ClitheroeCastle
{
    private GiftShop m_GiftShop;

    void Accept(IGiftShopVisitor visitor)
    {
         if (IsGiftShopOpen() == true)
         {
              visitor.VisitGiftShop(m_GiftShop);
         }
    }
}

class CaernarfonCastle
{
    private GiftShop m_FirstFloorGiftShop;

    void Accept(IGiftShopVisitor visitor)
    {
         if (IsGiftShopOpen() == true && IsShopPerformingStockTake() == false)
         {
              visitor.VisitGiftShop(m_FirstFloorGiftShop);
         }
    }
}
```

In the above the `Accept` method is the entry point¹. Every visitor starts off here and then is led around the castle without exposing details that are private or not relevant.

Hopefully this explains how the code that performs the action, buying a fridge magnet, is decoupled from whether, where and how it can be executed. The castle is the only class that knows whether you're allowed in, therefore it should be responsible for controlling that. This helps to ensure encapsulation of concerns.

There are downsides to this design, though. If you're not overly familiar with the pattern then it takes a bit of getting used to. There is a bit of additional code to write (in a sense you have to employ the tour guides). The action is split away from the original call site, which could make it harder to follow.

And what if you simply WANT to wander around the castle. Maybe you'll happen across the cafe and have a coffee. Maybe you will stumble into the gift shop buy a fridge magnet because you're there. That's fine too.

To implement this you'll need to embed the access logic in the visitor (the tourist) not the subject (the castle). Doing so means only this implementation (this tourist) will know how to abide by the castles’ rules and find the gift shop. The next tourist would need to learn or be given a copy of the rules and the map. I think the analogy is holding up, but let's take a look at what it would look like in code.

```csharp
void BuySomeFudge(CorfeCastle castle)
{
    if (castle.Shop.IsOpen && AmIWearingShorts() == false)
    {
        castle.Shop.BuyFudge();
    }
}

void BuySomeFudge(ClitheroeCastle castle)
{
    if (castle.GiftShop.IsOpen)
    {
        castle.GiftShop.BuyFudge();
    }
}

void BuySomeFudge(ClitheroeCastle castle)
{
    if (castle.FirstFloorGiftShop.IsOpen && castle.FirstFloorGiftShop.IsPerformingStockTake == false)
    {
        castle.FirstFloorGiftShop.BuyFudge();
    }
}
```

I know that you could use an interface or base class to help with the naming of (aka finding) the gift shop. I'm keeping things simple to illustrate the point. That is only one of the many problems that exist.

And to better highlight this, let's implement buying a fridge magnet.

```csharp
void BuyAFridgeMagnet(CorfeCastle castle)
{
    if (castle.Shop.IsOpen && AmIWearingShorts() == false)
    {
        castle.Shop.BuyAFridgeMagnet();
    }
}

void BuyAFridgeMagnet(ClitheroeCastle castle)
{
    if (castle.GiftShop.IsOpen)
    {
        castle.GiftShop.BuyAFridgeMagnet();
    }
}

void BuyAFridgeMagnet(ClitheroeCastle castle)
{
    if (castle.FirstFloorGiftShop.IsOpen && castle.FirstFloorGiftShop.IsPerformingStockTake == false)
    {
        castle.FirstFloorGiftShop.BuyAFridgeMagnet();
    }
}
```

Notice the copy paste of code³,⁴. What happens if the rules change and every tourist must present their ticket to gain entry⁴. All 6 methods above would need to change.

With this style each implementation could choose to ignore certain rules too⁴. In real world terms the tourist could take photos in a part of the castle where photos are banned. They could also give up after not finding the gift shop within a few minutes, even though it's on the first floor - where they didn't happen to look.

You also have to break [encapsulation](https://en.m.wikipedia.org/wiki/Encapsulation_(computer_programming)), the gift shop has to be made accessible to all, even if it is a private detail of the castle². Same goes for whether they are performing a stock take. It isn't something that should be in the public domain, but with this approach it has to be²,⁴.

Taking it further…
To illustrate further, here is how using the visitor pattern allows you to extend the model and capability with limited effort and code.

Visiting different types of subjects

```csharp
class CranmoreSteamRailway
{
    private GiftShop m_StationGiftShop;
    private GiftShop m_TrainGiftShop;

    void Accept(IGiftShopVisitor visitor)
    {
         if (IsGiftShopOpen() == true)
         {
              visitor.VisitGiftShop(m_StationGiftShop);
         }

         if (IsTrainMoving() == true)
         {
              visitor.VisitGiftShop(m_TrainGiftShop);
         }

    }
}
```

Visiting different components of a subject.

```csharp
interface ITouristVisitor
{
    void VisitGiftShop()
    { 
        /* empty default method, making it optional in visitor implementations */
    }

    void VisitCafe()
    {
        /* empty default method, making it optional in visitor implementations */
    }

    void VisitReception()
    {
        /* empty default method, making it optional in visitor implementations */
    }
}

class ColchesterCastle
{
    private GiftShop m_GiftShop;
    private Cafe m_Cafe;
    private Reception m_Reception;

    void Accept(ITouristVisitor visitor)
    {
         if (IsGiftShopOpen() == true)
         {
              visitor.VisitGiftShop(m_GiftShop);
         }

         if (IsCafeOpen() == true)
         {
             visitor.VisitCafe(m_Cafe);
         }

         visitor.VisitReception(m_Reception);
    }
}
```

A subject can implement an overload for the Accept method to allow different visitors. There is no rule to say there must be only one visitor for any given subject. I've chosen to demonstrate without method overloading for simplicity.

To wrap up, the visitor pattern [separates the concerns](https://en.m.wikipedia.org/wiki/Separation_of_concerns) of what some code can do from the thing that holds the information. The subject (the castle) allows you to access something, you (the tourist) chose what to do with that capability.

Because of this approach, you can apply the model across many different subjects (castles) for the same visitor (tourist). But also you can empower the visitor (tourist) to choose what they want to look at. The visitor can choose to visit the gift shop (implement VisitGiftShop) if they wish, but maybe they're only interested in visiting the cafe. That is their choice. All the subject (the castle) needs to do is allow them to do so once the checks have been completed.

I hope this helps explain the visitor pattern, and you understand how it works and where you may be able to use it. 

The visitor pattern is perfectly suited, but not limit to, to scenarios where…
- There are deep nested properties, e.g. trees
- There are rules about access to properties, e.g. security concerns and where encapsulation is key
- There are many variants of visitor OR subject

### A note on data collection
Imagine for a moment that you want to buy a fridge magnet at every castle gift shop you visit. The visitor is responsible for buying and therefore carrying around the purchased fridge magnets. As a result an implementation of the visitor could look like

```csharp
class BuyAFridgeMagnetVisitor : IGiftShopVisitor
{
    public readonly List<FridgeMagnet> FridgeMagnets { get; } = new();

    public void VisitGiftShop(GiftShop giftShop)
    {
        FridgeMagnets.Add(giftShop.BuyFridgeMagnet());
    }
}

ICastle[] castles = new[] { new CorfeCastle(), new ClitheroeCastle(), new CaernarfonCastle() };
var visitor = new BuyAFridgeMagnetVisitor();
foreach (car castle in castles)
{
    castle.Accept(visitor);
}
var allTheMagnets = visitor.FridgeMagnets;
```

See the following for extra reading or some real world examples
- [The expression visitor](https://learn.microsoft.com/en-us/dotnet/api/system.linq.expressions.expressionvisitor?view=net-9.0)
- [The game/reporting visitor - courage league](https://github.com/laingsimon/courage_scores/blob/505c4d57d3b41d27a2fa6c47c78639bc42433114/CourageScores/Models/Cosmos/Game/Game.cs#L95)
- [Low coupling is often thought to be a sign of a well-structured computer system](https://en.m.wikipedia.org/wiki/Coupling_(computer_programming))
- [Other design patterns](https://en.m.wikipedia.org/wiki/Software_design_pattern)
