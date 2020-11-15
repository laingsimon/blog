# Docker, in a corporate environment

Docker is great, I love it. You can do so much with it and quickly and easily too. Fantastic. However there are some gotchas, typically when you're working in a more corporate environment, the challenges I've had are described below...

## dotnet restore and artifactory (in a Unix container)
`dotnet restore` will restore packages for a dotnet project. You can specify your own sources, like artifactory, as you need.

But if these sources have internally signed certificates then dotnet restore won't know trust them. Unless you can access them via http, then you're in trouble, ish.

Simply put the Unix container doesn't know that the certificate supplied by artifactory is valid. You need to tell the container, not dotnet, that it is a valid certificate. You can follow the steps below to do this.

### 1. Download the certificate for the site
Go to the site in a browser and take a look at the certificate. If it is part of a certificate chain, then traverse the chain to find the top level certificate. This might be the organisations own internal certificate authority or something equivalent. If there isn't one, then use the certificate itself.

In Windows you can export the certificate to a `.cer` file. When doing this make sure you **pick base64 encoding**. Save the file using the wizard, then **rename the file to have a `.crt` extension**.

### 2. Update the docker file
Add a copy command to copy in the .crt file into the container. You'll need to copy it to the specific location in the container for Unix to pick it up.

You can use these command as a template.

```
#copy certificate
ADD ca.crt /usr/local/share/ca-certificates/ca.crt
#update attributes so it can be assimilated
RUN chmod 644 /usr/local/share/ca-certificates/ca.crt
```

Then you need to update docker to assimilate the certificate. Add the following command after the copy command.

```
RUN update-ca-certificates
```

### 3. wrapping it all up
Here is an example docker file showing all the steps

```
# Get Base Image (Full .NET Core SDK)
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS dotnet-run-base

# copy certificates
ADD ca.crt /usr/local/share/ca-certificates/ca.crt
RUN chmod 644 /usr/local/share/ca-certificates/ca.crt

RUN update-ca-certificates
```

 You can also use a powershell script to get the certificate you're looking for without needing to use the browser or mmc at all.

```powershell
Get-ChildItem -Path cert:\CurrentUser\CA `
	| Where-Object { $_.subject -eq "CN=MyCertificate" } `
	| ForEach-Object { 
		$cert = $_
		
		$crtContent = @(
			'-----BEGIN CERTIFICATE-----'
			[System.Convert]::ToBase64String($cert.RawData, 'InsertLineBreaks')
			'-----END CERTIFICATE-----'
		)
		
		$crtContent | Out-File -FilePath "ca.crt" -Encoding ascii
	}
```

## asp.net (core) Windows authentication in a Unix container
In short. It's not possible. The Unix container isn't joined to the domain, so it cannot authenticate with the DC correctly.

Instead, run the site via the dotnet command that you'd normally run in Windows. Update any other containers to communicate with this service using the `host.docker.internal` DNS name in Windows.

This works where you have an anonymous service than then uses windows auth to communicate out. If windows auth is required to communicate in, then you're not going to be able to containerise any service that communicates with it. Not in a Unix container at least.
