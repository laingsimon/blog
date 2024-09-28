# Unit testing, my story

I graduated from a software engineer degree in 2005. Software development was a well understood subject and the industry was booming, great, I landed on my feet.

I started off my career in a large business, learning the ropes from others. The real-world ropes, not the academic ones. I had a lot to learn, I didn't appreciate how much until many years later. 

One of the things that I can look back on now is the journey I've taken through unit testing. In 2005 it was next to non-existent. The tooling wasn't there for c++ and vb6. If it was then we weren't using it and I simply didn't know to look for it. This is so often the case, unit testing is an after thought to software development. It wasn't taught or even mentioned as part of my degree.

Shuffle forward a few years, I've moved into writing managed code, c# and VB.net. Frameworks exist for these languages now, but back in the day - circa 2007 - there wasn't. Once again I didn't know to look, but I was starting to change tack. I was noticing that if I could prove my code was correct before promptly and reliably, then it saved me time. For critical components I would write functions in the production code as a self-test. This isn't something I advise doing now, but at the time I wanted to protect against regression.

_Little did I know there were tools and frameworks out there._

I moved jobs again to a role where I probably learnt the most in my career. I learnt many things from the people I worked with, but the one thing that has shaped the way I work more than anything is unit testing. I learnt that there are tools out there, how to harness them and approaches to make the most of the practice. I'll be forever in the debt of the people I learnt from.

The time was 2010. I stayed there for about 6 years and in that time the landscape changed for software development, especially in the .net sphere. Microsoft updated Visual Studio to support unit testing as a first-class citizen. Other testing frameworks became available. Standards started to appear and more crucially it started to be talked about more.

Why, simply because *it makes you a better developer*. You write better code and that code is proven to do what you want it to. You can leverage [CI](https://en.m.wikipedia.org/wiki/Continuous_integration) and [CD](https://en.m.wikipedia.org/wiki/Continuous_delivery) pipelines with growing confidence and your velocity increases as a result.

If I could tell my former self (presuming the tooling was there and I simply didn't know about it) it would say.

- Always, _always_, **always** write unit tests with/at the same time as the code you write
- As a result always think about how it is going to be tested whilst writing it
- If you can, write your tests first. It saves time having to refactor things later (See [TDD](https://en.m.wikipedia.org/wiki/Test-driven_development))
- Run your tests as often as possible, don't wait until the end to pick up breaks
- Test everything, within reason, don't just test the happy path, the users will always do something unexpected

As a result my code is structured better from the outset. Each class has a single responsibility, and is proven to do what it should before it is released into the wild. My changes/implementations shouldn't get in the way of others due to things I've not tested. Also, others can use my tests to better understand what the code should be doing. The tests form a sort of documentation to the code in itself.

On a side note, unit testing can improve velocity and business confidence. They don't have to stop at testing classes and their interactions, you can use them to test integrations, interactions and more. The more that is automated, the less you have to do by hand. Yes there is a trade off, so you have to be pragmatic. But ask yourself, every time you want to deploy (or even merge something) do you want to run those manual tests again?

I've written tests to prove, amongst others that:
* Financial calculations - end to end - are correct for a number scenarios in a spreadsheet
   * Bespoke integration tests ran on every build
* There is parity between the original implementation of a library and a modernised version
   * Using docker to build a consistent 'backing environment' for every scenario
* The application, given inputs, emits the expected output at the very end
   * End to end tests, see Data helix generator and its end to end cucumber tests
* The application responds to user input in the right way
   * UI integration tests using selenium and webdriver

I was able to setup a CI and CD pipeline that was trusted by the business and the developers that meant we had visibility of the outcome of the tests as quickly as possible. We had post-deployment automation tests - written using a unit testing framework which gave a red/green signal immediately after a deployment. So much so, we were permitted (within reason) to deploy anytime.

Tools I've used:
- [NUnit](https://nunit.org)
- [Xunit](https://xunit.net/)
- MsTest (cards on the table, I'm not a fan)
- [Moq](https://github.com/moq/moq4) and [FakeItEasy](https://fakeiteasy.github.io/), before that [RhinoMocks](https://www.hibernatingrhinos.com/oss/rhino-mocks)
- [TestDriven.net](https://testdriven.net/) (back in the day!)
- [Dapper.MoqTests](https://github.com/laingsimon/Dapper.MoqTests)  (open source library to support additional testing)
- [NCrunch](https://www.ncrunch.net/)
- [Jasmine](https://jasmine.github.io/), [Karma](https://karma-runner.github.io/latest/index.html) and [Mocha](https://mochajs.org/)
- [PhantomJs](https://phantomjs.org/)
- [JUnit](https://junit.org/junit5/)
- [Mockito](https://site.mockito.org/)
- [Jest](https://jestjs.io/)
- [Cucumber](https://cucumber.io/) and [Specflow](https://specflow.org/)

### Code coverage note
One final note, on code coverage. Use it to help detect areas of code you've not tested when you're writing tests. That's it, end of. It's too blunt a tool to use for any other purpose. 

I've seen business set a threshold for expected unit test coverage. This sets an unhealthy expectation that developers should meet the code coverage target rather than writing good tests. Write good tests and code coverage will go up, don't try and meet the code coverage requirement to assume you have good tests.

### Final comments
To be clear, I learnt a lot from each experience and job I've had. I learnt whilst on the job, but more so from others around me - I thank you all. Also, I would do things differently now to what I would have done in 2010 and more so again from 2005. That's life, I don't regret what I've done (or didn't do) I've learnt to become better at what I do. Hopefully what I've said here might help you or someone else on their journey too.

---

[README](Home)
