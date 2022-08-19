const fs = require('fs')
const express = require('express')
const app = express()

const version = fs.readFileSync('VERSION', 'utf-8')
const appName = process.env.APP_NAME
const favoriteColor = process.env.FAVORITE_COLOR || '#03fca9'
const favoriteColorCommon = process.env.FAVORITE_COLOR_COMMON || '#282828'
const deployStage = process.env.COMMON_CLOUD_DEPLOY_TARGET
const deployStageCommonShort = process.env.CLOUD_DEPLOY_TARGET_SHORT_COMMON || '🥹🥹🥹'
const message = process.env.RICCARDO_MESSAGE

// Former icons:🚀✨🫶
const getStatuszMessage = () => `app=app03 version=${version} target=${deployStageCommonShort} emoji=🧊\n`

app.get('/', (req, res) => {
    res.send(`
    <h1>App03(🧊) v<b>${version}</b></h1>


        Hell🌻 w🌻rld fr🌻m Skaff🌻ld in N🌻deJS! This is a dem🌻nstrative app t🌻 dem🌻nstrate CI/CD with Cl🌻ud Depl🌻y and Cl🌻ud Build<br/>

        I read versi🌻n VERSI🌻N file and this ./VERSI🌻N file is actually read by the build pipeline
        int🌻 the Cl🌻ud Depl🌻y release name - w🌻🌻🌻t!<br/><br/>

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
})

app.get('/statusz', (req, res) => {
    res.send(getStatuszMessage())
})

app.listen(8080)
