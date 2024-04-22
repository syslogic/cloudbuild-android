/**
 * JetBrains Space Automation
 * This Kotlin script file lets you automate build activities
 * For more info, see https://www.jetbrains.com/help/space/automation.html
 */

job("Build Docker image") {
    startOn {
        gitPush { enabled = false }
    }
    host("Build Docker image") {
        dockerBuildPush {

            // Mapping Dockerfile build-time variables
            // The leading underscore provides compatibility towards Google Cloud Build.
            args["_CLI_TOOLS_VERSION"]    = "{{ project:CLI_TOOLS_VERSION }}"
            args["_ANDROID_SDK_PACKAGES"] = "{{ project:ANDROID_SDK_PACKAGES }}"
            args["_GRADLE_VERSION"]       = "{{ project:GRADLE_VERSION }}"

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
