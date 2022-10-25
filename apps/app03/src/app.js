/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

const fs = require('fs')
const express = require('express')
const app = express()

// chomping
const version = fs.readFileSync('VERSION', 'utf-8').split("\n")[0]
const appName = process.env.APP_NAME
const favoriteColor = process.env.FAVORITE_COLOR || '#03fca9'
const favoriteColorCommon = process.env.FAVORITE_COLOR_COMMON || '#282828'
const deployStage = process.env.COMMON_CLOUD_DEPLOY_TARGET
const deployStageCommonShort = process.env.CLOUD_DEPLOY_TARGET_SHORT_COMMON || '😢😭😢 '
const message = process.env.RICCARDO_MESSAGE

// Former icons:🚀✨🫶🧊 STATUSZ
const getStatuszMessage = () => `app=app03 version=${version} target=${deployStageCommonShort} emoji=🪢\n`

app.get('/', (req, res) => {
    res.send(`
    <h1>App03(🪢🧊) v<b>${version}</b></h1>


        Hell🌻 w🌻rld fr🌻m Skaff🌻ld in N🌻deJS! This is a dem🌻nstrative app t🌻 dem🌻nstrate CI/CD with Cl🌻ud Depl🌻y and Cl🌻ud Build<br/>

        I read versi🌻n VERSI🌻N file and this ./VERSI🌻N file is actually read by the build pipeline
        int🌻 the Cl🌻ud Depl🌻y release name - w🌻🌻🌻t!<br/><br/>

        Please help me choose the best icon for NodeJS: 🟢🟩📗🥬🍏💚🪢(knot=node)

        FAVORITE_COLOR=${favoriteColor}<br/>
        CLOUD_DEPLOY_TARGET=${deployStage} <br/>
        CLOUD_DEPLOY_TARGET_COMMON=${deployStageCommonShort} <br/>
        <br/>
        APP_NAME=${appName} <br/>
        RICCARDO_MESSAGE=${message}<br/>
        <br/>

        Link t🌻 <a href="/statusz" >Statusz</a>.
        <hr/>
          <center>
           <!-- /statusz --> ${getStatuszMessage()}
          </center>
    `)
    console.log(`/ (root) invoked: ${getStatuszMessage().replace(/[\n\r]+/g, '')}`);
})

app.get('/statusz', (req, res) => {
    res.send(getStatuszMessage());
    console.log(`/statusz (easter egg) invoked: ${getStatuszMessage().replace(/[\n\r]+/g, '')}`);
})

app.listen(8080)
