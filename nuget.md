# Nuget

Nuget is fantastic, I use it so much on a daily basis that I don't even notice it. It's intuitive and so easy to use. But.... There are occasions where I try and do something that steps a bit beyond the norm and it becomes a challenge.

Normally these are things that you can, and should be, doing with nuget. Such as content files wrapping up non-referenced binaries. Sometimes it is to work around issues with nuget itself, such as content files not traversing cascading references.

I've described some clarification to the spec and the workarounds I've needed for these (at least) below...

## binary contentFiles
Imagine you have a binary that needs to be shipped with your package. It might be an image, resource file or maybe even an exe. PhantomJs used to do this. You might have created a wrapper over the application in your .net code. Without the application it simply won't work, you need to include the file **and make sure it is copied to the project output directory**. Content files does this but to be clear this is what you'd need to do

`myApp.nuspec`
```
  <files>
	  <file src="myApp.exe" target="contentFiles/any/any" />
  </files>
```

This will ensure the application (myApp.exe) is copied to the output of the project that references this package. In visual studio you'll see a 'phantom file' which is the contentFile representation. You cannot remove this without removing the package, it's just the way it works.

That's it, and it all works as per the spec. Once you've done it once it makes sense and you probably never need to look at this document ever again, sadly the documentation doesn't current hit the mark for the first-time user as good as it could, on my opinion.

## cascading package contentFiles

`myWrapper.nuspec`
```
    <contentFiles>
      <files include="any/any/myApp.exe" buildAction="None" copyToOutput="true" />
    </contentFiles>
  </metadata>
```

If you have a package that emits an exe via content files. When you reference it directly it works perfectly. Let's call this `myApp.nupkg`.

If you have another package that references this package then it can see the contentFiles from `myApp.nupkg`. let's call this package `myWrapper.nupkg`. 

If you reference `myWrapper.nupkg` in a project, you **won't have the contentFiles from `myApp.nupkg` included in your project**. It's a bug, or missing feature in the _PackageReference_ implementation.
**I need to double check whether this answer solves this problem.**
https://stackoverflow.com/questions/61143283/copy-nuget-contentfiles-transitively-to-referenced-project

Currently there is no solution to this except chaining the contentFiles through the `myWrapper.nupkg`. This isn't ideal as your wrapper package contains the same content as the app package. In doing this you can (and in my opinion to save space/time should) remove the dependency `myApp.nupkg` from `myWrapper.nupkg`.

## Resources
- [PackageReference documentation](https://docs.microsoft.com/en-us/nuget/consume-packages/package-references-in-project-files)
- [nuget spec documentation](https://docs.microsoft.com/en-us/nuget/reference/nuspec)
