/**
 * JetBrains Space Automation
 * This Kotlin script file lets you automate build activities
 * For more info, see https://www.jetbrains.com/help/space/automation.html
 */

job("Build and push Docker image") {
    host("Build Docker image") {
        shellScript {
            content = """
                rm -R ./.github
                rm -R ./screenshots
                rm ./cloudbuild.yaml
                rm ./gradlew.bat
                rm ./.gitignore
                rm ./README.md
                rm ./LICENSE
            """
        }
        dockerBuildPush {

            // build-time variables
            args["_ANDROID_SDK_PACKAGES"] = "{{ project:ANDROID_SDK_PACKAGES }}"
            args["_GRADLE_WRAPPER_VERSION"] = "{{ project:GRADLE_WRAPPER_VERSION }}"

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
