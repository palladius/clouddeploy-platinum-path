const fs = require('fs')
const express = require('express')
const app = express()

const version = fs.readFileSync('VERSION', 'utf-8')
const appName = process.env.APP_NAME
const favoriteColor = process.env.FAVORITE_COLOR || '#03fca9'
const favoriteColorCommon = process.env.FAVORITE_COLOR_COMMON || '#282828'
const deployStage = process.env.CLOUD_DEPLOY_TARGET
const deployStageCommon = process.env.CLOUD_DEPLOY_TARGET_COMMON || '🥹🥹🥹'
const deployStageCommonShort = process.env.CLOUD_DEPLOY_TARGET_SHORT_COMMON || '🤯🤯🤯'
const message = process.env.RICCARDO_MESSAGE

const getStatuszMessage = () => `app=app03 (🌻) version=${version} target=${deployStageCommonShort} emoji=🥹\n`

app.get('/', (req, res) => {
    res.send(`
    <h1>App03 (🌻) v<b>${version}</b></h1>

    
        Hello world from Skaffold in NodeJS! This is a demonstrative app to demonstrate CI/CD with Cloud Deploy and Cloud Build<br/>

        I read version from package.json file and this ./VERSION file is actually read by the build pipeline
        into the Cloud Deploy release name - wOOOt!<br/><br/>

        FAVORITE_COLOR=${favoriteColor}<br/>
        CD_TARGET=${deployStage} <br/>
        CLOUD_DEPLOY_TARGET_COMMON=${deployStageCommon} <br/>
        <br/>
        APP_NAME=${appName} <br/>
        RICCARDO_MESSAGE=${message}<br/>
        <br/>

        Favorite Color COMMON from v1.35: <b style='background-color:${favoriteColorCommon};' >${favoriteColorCommon}</b><br/>
        Favorite Color from v1.4: <b style='background-color:${favoriteColor};' >${favoriteColor}</b><br/>

        Link to <a href="/statusz" >Statusz</a>.
        <hr/>
          <center>
           <!-- /statusz --> ${getStatuszMessage()}
          </center>
    `)
})

app.get('/statusz', (req, res) => {
    res.send(getStatuszMessage())
})

app.listen(8080)
