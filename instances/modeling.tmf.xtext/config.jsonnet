local permissionsTemplates = import '../../templates/permissions.libsonnet';
{
  project+: {
    fullName: "modeling.tmf.xtext",
    displayName: "Eclipse Xtext",
    resourcePacks: 2,
  },
  jenkins+: {
    // workaround to avoid errors, when the Gerrit plugin is disabled
    permissions: permissionsTemplates.projectPermissions($.project.unixGroupName, permissionsTemplates.committerPermissionsList),
    staticAgentCount: 2,
    plugins+: [
      "copyartifact",
      "downstream-buildview",
      "envinject",
      "gradle",
      "groovy",
      "htmlpublisher",
      "parameterized-scheduler",
      "show-build-parameters",
      "slack",
      "build-user-vars-plugin"
    ],
  },
  gradle+: {
    generate: true,
  },
  clouds+: {
    kubernetes+: {
      local currentCloud = self,
      templates+: {
        "centos-7-6gb": currentCloud.templates["centos-7"] {
          labels: ["centos-7-6gb"],
          kubernetes+: {
            resources+: {
              memory: {
                limit: "6144Mi",
                request: "6144Mi",
              },
            },
          },
        },
      },
    },
  },
  maven+: {
    files+: {
      "settings.xml"+: {
        "servers"+: {
          "ossrh-s01": {
            nexusProUrl: "https://s01.oss.sonatype.org",
            username: {
              pass: "bots/" + $.project.fullName + "/oss.sonatype.org/username",
            },
            password: {
              pass: "bots/" + $.project.fullName + "/oss.sonatype.org/password",
            },
          },
        },
      },
    }
  }
}
