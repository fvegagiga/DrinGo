# DrinGo

[![Build Status](https://travis-ci.org/fvegagiga/DrinGo.svg?branch=main)](https://travis-ci.org/fvegagiga/DrinGo)

DrinGo is an iOS app to discover the best cocktails and drink recipes.



### Story: Customer requests to random cocktail list

### Narrative #1

> As an online customer
I want the app to automatically load a random cocktail list
So I can always enjoy a new cocktail

### Scenarios (Acceptance criteria)

```
Given the customer has connectivity
When the customer requests to load a random cocktail list
Then the app should display the cocktail list from remote
And replace the cache with the new list
```

### Narrative #2

> As an offline customer
I want the app to show the latest saved version of my cocktail list
So I can always enjoy some cocktails

### Scenarios (Acceptance criteria)

```
Given the customer doesn’t have connectivity
And there’s a cached version of the cocktail list
When the customer requests to see the list
Then the app should display the latest list saved

Given the customer doesn’t have connectivity
And the cache is empty
When the customer requests to see the cocktail list
Then the app should display an error message
```

## Architecture

![Random Cocktail List Loading Feature](cocktail_list_feature_architecture)
