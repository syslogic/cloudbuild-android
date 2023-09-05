/**
 * JetBrains Space Automation
 * This Kotlin script file lets you automate build activities
 * For more info, see https://www.jetbrains.com/help/space/automation.html
 */

job("Build and push Docker image") {
    host("Build Docker image") {
        dockerBuildPush {

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
            tags {
                +"{{ project:DOCKER_IMAGE }}:0.${"$"}JB_SPACE_EXECUTION_NUMBER"
                +"{{ project:DOCKER_IMAGE }}:lts"
            }
        }
    }
}
