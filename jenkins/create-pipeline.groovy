import jenkins.model.*
import hudson.security.*
import org.jenkinsci.plugins.workflow.job.*
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition
import hudson.plugins.git.*
import com.cloudbees.jenkins.GitHubPushTrigger

// Get Jenkins instance
Jenkins jenkins = Jenkins.getInstance()

// Create admin user
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "admin")
jenkins.setSecurityRealm(hudsonRealm)

// Set authorization strategy
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
jenkins.setAuthorizationStrategy(strategy)

// Save config
jenkins.save()

// Create pipeline job if it doesn't exist
def jobName = "nodejs-deploy-job"
if (jenkins.getItem(jobName) == null) {
    def job = jenkins.createProject(WorkflowJob, jobName)

    def scm = new GitSCM(
        [new UserRemoteConfig("https://github.com/gowthamchi/terraform-jenkins-ec2-setup.git", null, null, null)],
        [new BranchSpec("*/main")],
        false, [], null, null, []
    )

    def flowDef = new CpsScmFlowDefinition(scm, "jenkins/jenkinsfile")
    flowDef.setLightweight(true)
    job.setDefinition(flowDef)

    // Add GitHub webhook trigger
    def trigger = new GitHubPushTrigger()
    trigger.start(job, true)
    job.addTrigger(trigger)

    job.save()
}
