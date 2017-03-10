# iOS OAuth app
![Screenshot of the app displaying an OAuth token](screenshot.png)

### Setup

Follow the **download steps** in [Getting the SDK](../../getting-the-sdk.md) and drop it into `Frameworks`. You won't need the **configuration steps**.

### App notes

Sample configuration - note that all values are configurable on ISAM:

key | value
------- | -------
Username | testuser1
Password | user'sP@$$w0rd
Token URL | https://\<my isam\>/mga/sps/oauth/oauth20/token
Client ID | MyClientId
Client secret | TheClientSecret (or blank for a public client)

If you're using a development machine without a valid certificate, you may wish to consult the [certificate pinning](../../certificate-pinning.md) documentation.

# License

This sample app is intended solely for use with an Apple iOS product and intended to be used in conjunction with officially licensed Apple development tools and further customized and distributed under the terms and conditions of your licensed Apple developer program.

    Copyright 2017 International Business Machines

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
