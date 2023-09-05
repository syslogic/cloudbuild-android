/**
 * JetBrains Space Automation
 * This Kotlin script file lets you automate build activities
 * For more info, see https://www.jetbrains.com/help/space/automation.html
 */

job("Build and push Docker") {

    // both 'host.shellScript' and 'host.dockerBuildPush' run on the same host
    host("Build artifacts and a Docker image") {

        // Gradle build creates artifacts in ./build
        // shellScript {
        //     content = """
        //         ./gradlew build
        //     """
        // }

        // Note that if Dockerfile is in the project root, we don't specify its path.
        // We also imply that Dockerfile takes artifacts from ./build and puts them to image
        // e.g. with 'ADD /build/app.jar /root/home/app.jar'
        dockerBuildPush {

            // by default, the step runs not only 'docker build' but also 'docker push'
            // to disable pushing, add the following line:
            // push = false

            // path to Docker context (by default, context is working dir)
            // context = "docker"
            // path to Dockerfile relative to the project root
            // if 'file' is not specified, Docker will look for it in 'context'/Dockerfile
            // file = "docker/config/Dockerfile"

            // build-time variables
            args["_ANDROID_SDK_PACKAGES"] = "platform-tools platforms;android-34 build-tools;34.0.0"
            args["_GRADLE_WRAPPER_VERSION"] = "8.2"

            // image labels
            labels["vendor"] = "syslogic"

            // to add a raw list of additional build arguments, use
            // extraArgsForBuildCommand = listOf("...")

            // to add a raw list of additional push arguments, use
            // extraArgsForPushCommand = listOf("...")

            // image tags
            val repo = {{ DOCKER_IMAGE }}
            tags {
                +"$repo:0.${"$"}JB_SPACE_EXECUTION_NUMBER"
                +"$repo:lts"
            }
        }
    }
}