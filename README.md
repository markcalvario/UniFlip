# UniFlip

## Table of Contents
1. [Overview](#Overview)
2. [Demo](#Demo)
3. [Product Spec](#Product-Spec)
5. [Wireframes](#Wireframes)
6. [Schema](#Schema)
7. [API Endpoints](#API-Endpoints)

## Overview
### Description
College marketplace for a colleges (e.g. only affiliates of a school/university ) & can be entered to the college marketplace by verifying their status within the college. A new user would have to verify that they attend the university to successfully create an account. Users can upload listings of products or services such as photography or a used fridge. This marketplace allows for the use of one platform while building a stronger student community as students help other students.

### App Evaluation
[Evaluation of your app across the following attributes]
- **Category:** Social, Buy/Sell, Marketplace
- **Mobile:** Users need a phone to take a picture of their college/university ID so that their identity can be verified. Notifications can be sent to users regarding an interest in buyers or sellers.
- **Story:** Creates a marketplace between students/affiliates so that they can help each other out. Allows students/affiliates of a certain community to get their services out into their own community.
- **Market:** Any university or college student that can verify their status within the university are able to utilize this app. Custom features could be used for monetization such as ads or taking 5-10% of sales. 
- **Habit:** Students/affiliates are constantly using this app whenever they need a service or buy an item. Sellers can sell or offer services for money while buyers are constantly looking.
- **Scope:** First we can have a simple marketplace for each university. We can then add machine learning in the future to add a more personal feed.

## Demo


## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can login with their username and password
* User can see an alert if they failed to login
* User can sign up with their school email, a username, and password
* User can see a list of universities to select their current school
* User can see an alert upon a successful registration
* User is redirected to the default mail app to verify their email upon successfully registering
* User can switch between the home, sell, and profile screens through the tabs at the bottom
* User can see all the listings by category that were uploaded to their university in the home screen
* User can tap the save icon to save or unsave a listing depending on whether they already saved it or not 
* User can tap the search bar and see suggested listings
* User can tap the search bar to search for listings
* User can tap the save button in the listings results of a search to save or unsave a listing
* User can tap a listing to see more details of that listing
* User can upload more one photo of a listing 
* User can type in the title, category, description, price, location, type, brand, and condition of listing
* User can tap the location field to fill out the location of where their location is at by using Google's Autocomplete API and a tableview is used display the location search
* User can tap the category field to be redirected to another view so that the user can select the appropiate category of their listing
* User can tap the 'post listing' button to post their listing if the user filled out all the required inputs to sell 
* User is redirected to the home screen to see their posted listing
* User can tap the listing image in the listing details screen to see a fade in/fade out transition into the full image of the listing image tapped
* User can zoom into the listing image by pinching
* User can tap the save button on the top right to save or unsave a listing in the listing details screen
* User can tap the 3-horizontal dots (menu) to view more options such as reporting an inappropiate listing, emailing the author of the listing, and delete the listing if they are the author of the listing
* User can tap the report button to open a report model view controller where they can write a reason for the report 
* User can tap "report" to submit the report
* User can tap the mail icon in the listing detail screen to email the author of the listing
* User can tap the profile picture of the author of the listing to view their profile
* User can switch between "Listings" and "Saved" to see the listings saved or listings posted by the user a user is viewing through the TabBar
* User can tap the settings button to change their profile picture and/or their bio
* User can tap the checkmark button in the top right of the settings screen to save any changes to their profile
* User can select from either camera or camera roll to upload a picture
* User can see a list of suggested listings based on their clicking of profiles, listings, and categories
* User can see a successful registration acount alert where they are redirected to the mail app
* User can logout
* User can stay logged in if their app restarts

**Optional Features**
* User can search by users
* User can follow or unfollow other users
* User can send an email to another user through their profile
* User can delete a listing if they are the author and sold their item
* User can add multiple images when they post a listing
* User can view the multiple images that were posted to a listing
* User can see an unsuccessful login alert
* User can use UniFlip in other devices that have different screen sizes without the design being messed up 
* User can see their following count
* User can view all the listings under a certain category
* User can use the scope bar to search for a user or listing
* User can use accessiblity features to have the labels, buttons, and images pronounced aloud
* User can see a network error alert if they are not connected to the internet
* User can see Google's Snackbar design with a message if a user does not fill out all the required fields or if they already reported a user 
* User can see the listing title or the username highlighted in blue if the search string matches part of the listing title or profile username
* User can tap profiles that appear in the search results to view that user's profile
* User can delete an uploaded photo before posting a listing
* User can tap the view all button to see all the listings of a certain category
* User can slide to the left to see more images of that listing, if applicable 
* User can see a Page Control to see what image they are viewing
* User can refresh their feed by sliding up in the home screen
* User can see Google's activity indicator to show that the data is loading

### 2. Screen Archetypes
* Login Screen
  * User can login
* Registration Screen
  * User can create a new account
* Home Screen
  * User can view a feed of listings based on their university
  * User can save listings
  * User can search for other users
  * User can search through listings
* Post a listing screen
  * User can post a listing by filling out all the required inputs
* Report Screen 
  * User can report a listing by typing in the text area within the report screen; viewing as a modal
* Edit Profile Screen
  * User can edit their profile picture and/or profile bio
* Select Option Screen
  * When filling out the location and category fields in the sell screen, the user will be redirected to the select option screen to pick a location using Google Autocmple or pick a category by tapping on tableview cell
* Listing By Category Screen
  * User can tap the "view all" button to view all listings that fall under a certain category and will be redirected to the listing by category screen

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Home
* Profile
* Creation

**Flow Navigation** (Screen to Screen)

* Login Screen
   * To New Account Screen if no account has been created
   * Home
* New Account Screen
   * Login Screen
* Home
   * View listings by category screen
   * listing detail screen
* Listing Detail Screen
   * Profile Screen
   * Report Listing Screen
* Profile Screen
   * Listing Detail Screen
   * Edit Profile Screen
* Sell Screen
   * Home Screen once their listing was successfully uploaded 

## Wireframes
[Add picture of your hand sketched wireframes in this section]
<img src="https://user-images.githubusercontent.com/58496944/126407796-b01248e7-b14c-46b9-97db-81434225b41a.jpeg" width=600>

## Schema 
Using Parse backend. I have three models: users, listings, reports, and marketplace.

[Schema.xlsx](https://github.com/markcalvario/UniFlip/files/6910902/Schema.xlsx)
[Schema - Sheet1.csv](https://github.com/markcalvario/UniFlip/files/6910904/Schema.-.Sheet1.csv)

Models:

User

| Property |  Type     |  Description |
| -------- |  -------- | ------------ |
| objectID |  String | automatically generated by Parse |
| username |  String | username created by the user |
| password |  String | password created by the user |
| email |     String | school email provided by the user |
| profilePicture  | File | file containing the user's profile picture |
| university |  String | university that the user selected |
| createdAt |  String | timestamp of when this User object was created|
| updatedAt |  String | timestamp of when this User object was updated |
| emailVerified |  Boolean | verification status|
| biography |  String | bio created by the user when they edit their profile|
| visitedProfileToCounter | Dictionary | updated everytime a user visits another user's profile, keeps track of how many times they clicked|
| visitedListingToCounter |  Dictionary | updated everytime a user visits another user's listings, keeps track of how many times they clicked that listing|
| visitedCategoryToCounter |  Dictionary | updated everytime a user visits a certain category, keeps track of how many times they clicked that category|

Listing

| Property |  Type     |  Description |
| -------- |  -------- | ------------ |
| objectID | String| automatically generated by Parse|
| imagesOfProduct | Array of PFFiles | contains all the images of the listing provided by the user|
| titleOfProduct| String| the title of the listing provided by the user |
|description| String| the description of the listing provided by the user |
|category| String| the category of the listing provided by the user|
|price| String| the price of the listing provided by the user |
|createdAt| String| timestamp of when the Listing was created|
|updatedAt| String| timestamp of when the Listing was last updated|
|brand| String| the brand of the listing provided by the user|
|location| String | the location of the listing provided by the user|
|isReported| Boolean | if the listing has been reported|
|reportCount| Integer | number of users who have reported this listing|
|Condition| String | the condition of the listing provided by the user|
|author| Pointer to User object | the user who created the listing object |
|savedBy| Array of User pointers | users who have saved this listing|
|isSaved| Boolean | if the listing has been saved |
|saveCount| Integer | the number of users who have saved this listing |
|authorEmail| String | the email of the author of this listing |

Market

| Property |  Type     |  Description |
| -------- |  -------- | ------------ |
|objectID| String | unique identifier created by parse|
|createdAt| String| timestamp of when this Market object was created|
|updatedAt| String| timestamp of when this Market object was updated |
|users| Array of User pointers| users that belong to this marketplace |
|university| String | name of the school for this marketplace |

Report

| Property |  Type     |  Description |
| -------- |  -------- | ------------ |
|objectID| String | automatically generated by Parse (unique)|
|createdAt| String| timestamp of when this Report object was created|
|updatedAt| String| timestamp of when this Report object was updated|
|reason| String| reason for why the listing was reported|
|listing| Pointer to Listing object |pointer to the listing that was reported|

## API Endpoints

Google SDK for iOS
https://developers.google.com/maps/documentation/places/ios-sdk/overview


Hippo's University Domains and Names API
http://universities.hipolabs.com/search?country=united+states





