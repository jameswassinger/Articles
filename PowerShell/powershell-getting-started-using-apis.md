# PowerShell: Getting Started Using APIs

The official definition of an Application Programming Interface (API) is a system of programming tools that enables a program to communicate with another program or an operating system, and that helps software developers create their own applications ([Oxford Dictionaries](https://www.oxfordlearnersdictionaries.com/us/definition/english/application-programming-interface?q=application+programming+interface)).

The apps that you use everyday utilize APIs to communicate with servers. The API retrieves data for the application to display. The API acts as a middleman between the application UI and the server, where the data is stored.

A non-tech example of an API, think about your most recent trip to a fast-food restaurant. You walked up to the counter, reviewed the menu, and placed your order with the cashier. The cashier then delivered your request to the prep counter where the order was processed. The cashier then provided you, with your order after the prep counter finished processing the order.

APIs follow a similar process from the previous fast food example. For instance, a mobile application will use an API to request data from a server, the server authenticates the request, processes the authenticated request, and then the API delivers the requested data back to the application. The application interface makes the data presentable to the user in a readable layout.

## Discover APIs

What APIs are available? A Google search will provide some good options of APIs that are available. Here are some good resources for finding an API to use:

- P[rogrammableWeb](https://www.programmableweb.com/api/coronavirus-rest-api-v10)
- [Public APIs](https://github.com/public-apis/public-apis)
- [RapidAPI.com](https://rapidapi.com/)

## Starting Small

To get started working with APIs, let's build a simple PowerShell name generator application powered mainly by an API.

Hop over to the [Public API page](https://github.com/public-apis/public-apis), from the index click on the [Test Data](https://github.com/public-apis/public-apis#test-data) category. We will be using the [UI Names](https://github.com/thm/uinames) API to power this application.

```powershell
https://uinames.com/api/
```

Open a Windows PowerShell ISE or Visual Studio Code, and enter in the below line. We will first create a PowerShell variable named $webData. The $webData requests the UI Names API.

```powershell
# grab the data
$webData = Invoke-WebRequest -Uri "https://uinames.com/api/"
```

We can test the above variable by typing the line in a PowerShell console. Below is the output of the $webData variable.

```powershell
# what is stored in the variable
$webData

# Output
StatusCode        : 200
StatusDescription : OK
Content           : {"name":"Didina","surname":"Iliescu","gender":"female","region":"Romania"}
RawContent        : HTTP/1.1 200 OK
                    Transfer-Encoding: chunked
                    Connection: keep-alive
                    Access-Control-Allow-Origin: *
                    Access-Control-Allow-Methods: GET
                    CF-Cache-Status: DYNAMIC
                    Expect-CT: max-age=604800, report-uri=...
Forms             : {}
Headers           : {[Transfer-Encoding, chunked], [Connection, keep-alive], [Access-Control-Allow-Origin, *], [Access-Control-Allow-Methods, GET]...}
Images            : {}
InputFields       : {}
Links             : {}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 74
```

By testing the variable in a PowerShell console you can see what the $webData variable is pulling from the API. The important line is the JSON data that is now being stored in the $webData under the Content object.

Now that we know how to access the data we need from the API. We are going to modify the $webData variable. The modification will grab the JSON data and then pipe the content to the ConvertFrom-Json PowerShell Cmdlet. The ConvertForm-Json cmdlet turns a JSON string into PS objects for each property in the JSON string.

```powershell
# shorten up the code to call and convert to JSON in one line. 
$webData = $(Invoke-WebRequest "https://uinames.com/api/").Content | ConvertFrom-Json
```

At this point open or clear out a PowerShell console and enter in the below for loop. The for loop is testing the $webData variable and then returns five names. If you tested out the for loop in your PowerShell console and received five names proceed, else review the previous steps to see what you may have missed.

```powershell
# generate 5 names anymore and you will receive request errors. 
for($i = 0; $i -le 5; $i++) {
	$webData = $(Invoke-WebRequest "https://uinames.com/api/").Content | 		ConvertFrom-Json
	Write-Host $($webData.Name)
}

# Output
肖肖
Amalia
Vendelín
Selma
Georgian
Bonifác
```

Now that we can successfully request the API and get the data we need, let's create a function to get a name from the API each time we run the function.

```powershell
# there is other data, but let's keep it simple and use the name. 
# random name generator.

# function to grab a random name from the api
function getName {
	$webData = $(Invoke-WebRequest "https://uinames.com/api/").Content | ConvertFrom-Json
 return $webData
}
```

Great! Now let's create a while loop that will ask for a greeting, e.g. Hello, and return a name until the exit string is entered into the greeting.

```powershell
# the program
while(!($exit)) {
	$greeting = Read-Host "Enter a greeting"
	if($greeting -eq "exit") {
		$exit = $true
	} else {
 		Write-Host "$greeting, $(getName)`n"
 	}
}

# output 
Enter a greeting: Hello
Hello, Skye

Enter a greeting: Welcome
Welcome, Relu

Enter a greeting: What! What!
What! What!, Iosif

Enter a greeting: Great Job!
Great Job!, Michael

Enter a greeting: exit
```

Excellent! If you got similar output from the above then you successfully created the small name generator PowerShell application.

## One More Simple Sample

Let's create one more PowerShell application with an API that will calculate the Love compatibility & chances of a successful love relationship when provided two names.

For this application, you will need to sign-up for an account at [Rapidapi.com](https://rapidapi.com/). After signing up, search for the [Love Calculator API](https://rapidapi.com/ajith/api/love-calculator/). We will be using the Love Calculator API to create a Love Calculator application with PowerShell.

> **Warning** This application is for entertainment purposes only.

Open a PowerShell ISE or Visual Studio Code. Add two variables $nameA and $nameB. For $nameA the value of the variable should be Read-Host, Enter a name. For $nameB the value of the variable should be Read-Host, Enter another name.

```powershell
$nameA = Read-Host "Enter a name"
$nameB = Read-Host "Enter another name"
```

Create a third variable named $uri and set the value to the Love Calculator API URL that gets the percentage and results. Modify the API URL to include the two name variables.

```powershell
$uri = "https://love-calculator.p.rapidapi.com/getPercentage?fname=$nameA&sname=$nameB"
```

The next part is adding the $headers hash table, which will be used to Splat the header parameters into the Invoke-RestMethod cmdlet we will be using. The $headers hash will consist of the Host API Url and the API Secret Key (the key is generated for you in your [RapidApi.com](http://rapidapi.com/) account).

```powershell
$headers=@{}
$headers.Add("x-rapidapi-host", "love-calculator.p.rapidapi.com")
$headers.Add("x-rapidapi-key", "YOUR-SECRET-KEY")
```

Add a $response variable that contains the Invoke-RestMethod to request the API (the exact settings to use when requesting this API are obtained from [RapidApi.com](http://rapidapi.com/)).

```powershell
$response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers
```

Now to finish it up, add a Write-Host to return the results. The $response contains the requested data and can be accessed by (.) notation.

If you open a separate PowerShell console and enter in what we have thus far you can see what the $response returns so you know what PowerShell objects to access from the $response variable.

```powershell
# Example Output from the $response var
fname sname percentage result
----- ----- ---------- ------
Jane  John  36         Can choose someone better.
```

From the output above you can see we can get the results from the percentage and result properties.

```powershell
Write-Host "$nameA and $nameB are $($response.percentage)% compatible. $($response.result)"
```

Put it all together. Here is the full script and an example output.

```powershell
$nameA = Read-Host "Enter a name"
$nameB = Read-Host "Enter another name"

$uri = "https://love-calculator.p.rapidapi.com/getPercentage?fname=$nameA&sname=$nameB"

    $headers=@{}
    $headers.Add("x-rapidapi-host", "love-calculator.p.rapidapi.com")
    $headers.Add("x-rapidapi-key", "YOUR-API-KEY")
    $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers

Write-Host "$nameA and $nameB are $($response.percentage)% compatible. $($response.result)"
```

```powershell
# Output
Enter a name: John
Enter another name: Jane
John and Jane are 36% compatible. Can choose someone better.
```

## Extend Your Knowledge

Now that you have created two simple applications using two separate APIs. Extend your knowledge further by searching for additional APIs to use from one of the API resources previously mentioned in this article.

You can also try to extend the simple apps that we created in this article. Here are some things you can add to the applications to further test and expand your knowledge.

In the Name Generator try the following:

- Allow the user to enter X number of names to generate and then have the app generate the X amount of names.
- Error handling
- Validation

In the Love Calculator try the following:

- Allow the user to continue using the app until a termination command is entered.
- Add input validation
- Add Error Handling
