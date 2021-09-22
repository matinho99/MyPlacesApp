# MyPlacesApp

## Description

This app allows its users to manage their favourite places, create lists and assign places to lists. Main motivation for this app was polishing my Salesforce skills. Other reason for this project came after I had lost all my saved places and favourite lists in Google Maps. This led me to think - "Why not do it myself in Salesforce and see how it goes?" - and here we are.

This app allows its users to quickly see their created lists and places assigned to them as well as search for new places, which underneath utilizes Google Places API. The app was designed with both desktop and mobile users in mind, and was tested for both device types.

If you want to test the app yourself, see below for instructions how to set it up.

## Setup requirements

- [Salesforce CLI](https://developer.salesforce.com/tools/sfdxcli) to deploy package to your org
- created Google Cloud Platform project with a generated API key to allow usage of Places API - steps can be found [here](https://cloud.google.com/resource-manager/docs/creating-managing-projects#creating_a_project) and [here](https://cloud.google.com/docs/authentication/api-keys#creating_an_api_key)

## Setup

### Deployment

1. Open terminal and go to the folder containing this project.
2. If you haven't authenticated your org in SFDX, use:
   ```
   sfdx auth:web:login -a <alias> -s [-r <instanceUrl>]
   ```
   where:
   - `-a <alias>` - alias for the authenticated org
   - `-s` - set authenticated org as default for SFDX commands
   - `-r <instanceUrl>` - instance url of the org. This is needed if the org is a sandbox - the value should be `https://test.salesforce.com` in this case. In other cases, this can be omitted.
3. Deploy the package to your org using:
   ```
   sfdx force:source:deploy -x .\package.xml
   ```
### App configuration

#### Create users

1. In your org, go to `Setup`.
2. In Quick Find, search for Users. Go to `Users`.
3. Click `New User`.
4. For profile select `MyPlaces Admin` profile. Set other fields as you like.
5. `Save`.
6. Repeat steps 3-5, but this time - select `MyPlaces User` as profile.

#### Set app's API key
 
1. In your org, go to `Setup`.
2. In Quick Find, search for Custom Settings. Go to `Custom Settings`.
3. Click `Manage` next to MyPlaces_Settings.
4. Click `Edit`.
5. Paste your Google Platform project's API key into `Google Places API Key` field.
6. `Save`.