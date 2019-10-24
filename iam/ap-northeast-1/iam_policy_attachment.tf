resource "aws_iam_policy_attachment" "APIGatewayServiceRolePolicy" {
  name       = "APIGatewayServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/APIGatewayServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AWSAccountActivityAccess" {
  name       = "AWSAccountActivityAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSAccountActivityAccess"
}

resource "aws_iam_policy_attachment" "AWSAccountUsageReportAccess" {
  name       = "AWSAccountUsageReportAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSAccountUsageReportAccess"
}

resource "aws_iam_policy_attachment" "AWSAgentlessDiscoveryService" {
  name       = "AWSAgentlessDiscoveryService"
  policy_arn = "arn:aws:iam::aws:policy/AWSAgentlessDiscoveryService"
}

resource "aws_iam_policy_attachment" "AWSAppMeshFullAccess" {
  name       = "AWSAppMeshFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSAppMeshFullAccess"
}

resource "aws_iam_policy_attachment" "AWSAppMeshReadOnly" {
  name       = "AWSAppMeshReadOnly"
  policy_arn = "arn:aws:iam::aws:policy/AWSAppMeshReadOnly"
}

resource "aws_iam_policy_attachment" "AWSAppSyncAdministrator" {
  name       = "AWSAppSyncAdministrator"
  policy_arn = "arn:aws:iam::aws:policy/AWSAppSyncAdministrator"
}

resource "aws_iam_policy_attachment" "AWSAppSyncInvokeFullAccess" {
  name       = "AWSAppSyncInvokeFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSAppSyncInvokeFullAccess"
}

resource "aws_iam_policy_attachment" "AWSAppSyncPushToCloudWatchLogs" {
  name       = "AWSAppSyncPushToCloudWatchLogs"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppSyncPushToCloudWatchLogs"
}

resource "aws_iam_policy_attachment" "AWSAppSyncSchemaAuthor" {
  name       = "AWSAppSyncSchemaAuthor"
  policy_arn = "arn:aws:iam::aws:policy/AWSAppSyncSchemaAuthor"
}

resource "aws_iam_policy_attachment" "AWSApplicationAutoScalingCustomResourcePolicy" {
  name       = "AWSApplicationAutoScalingCustomResourcePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSApplicationAutoScalingCustomResourcePolicy"
}

resource "aws_iam_policy_attachment" "AWSApplicationAutoscalingAppStreamFleetPolicy" {
  name       = "AWSApplicationAutoscalingAppStreamFleetPolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSApplicationAutoscalingAppStreamFleetPolicy"
}

resource "aws_iam_policy_attachment" "AWSApplicationAutoscalingDynamoDBTablePolicy" {
  name       = "AWSApplicationAutoscalingDynamoDBTablePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSApplicationAutoscalingDynamoDBTablePolicy"
}

resource "aws_iam_policy_attachment" "AWSApplicationAutoscalingEC2SpotFleetRequestPolicy" {
  name       = "AWSApplicationAutoscalingEC2SpotFleetRequestPolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSApplicationAutoscalingEC2SpotFleetRequestPolicy"
}

resource "aws_iam_policy_attachment" "AWSApplicationAutoscalingECSServicePolicy" {
  name       = "AWSApplicationAutoscalingECSServicePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSApplicationAutoscalingECSServicePolicy"
}

resource "aws_iam_policy_attachment" "AWSApplicationAutoscalingEMRInstanceGroupPolicy" {
  name       = "AWSApplicationAutoscalingEMRInstanceGroupPolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSApplicationAutoscalingEMRInstanceGroupPolicy"
}

resource "aws_iam_policy_attachment" "AWSApplicationAutoscalingRDSClusterPolicy" {
  name       = "AWSApplicationAutoscalingRDSClusterPolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSApplicationAutoscalingRDSClusterPolicy"
}

resource "aws_iam_policy_attachment" "AWSApplicationAutoscalingSageMakerEndpointPolicy" {
  name       = "AWSApplicationAutoscalingSageMakerEndpointPolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSApplicationAutoscalingSageMakerEndpointPolicy"
}

resource "aws_iam_policy_attachment" "AWSApplicationDiscoveryAgentAccess" {
  name       = "AWSApplicationDiscoveryAgentAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSApplicationDiscoveryAgentAccess"
}

resource "aws_iam_policy_attachment" "AWSApplicationDiscoveryServiceFullAccess" {
  name       = "AWSApplicationDiscoveryServiceFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSApplicationDiscoveryServiceFullAccess"
}

resource "aws_iam_policy_attachment" "AWSArtifactAccountSync" {
  name       = "AWSArtifactAccountSync"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSArtifactAccountSync"
}

resource "aws_iam_policy_attachment" "AWSAutoScalingPlansEC2AutoScalingPolicy" {
  name       = "AWSAutoScalingPlansEC2AutoScalingPolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSAutoScalingPlansEC2AutoScalingPolicy"
}

resource "aws_iam_policy_attachment" "AWSB9InternalServicePolicy" {
  name       = "AWSB9InternalServicePolicy"
  policy_arn = "arn:aws:iam::aws:policy/AWSB9InternalServicePolicy"
}

resource "aws_iam_policy_attachment" "AWSBackupAdminPolicy" {
  name       = "AWSBackupAdminPolicy"
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupAdminPolicy"
}

resource "aws_iam_policy_attachment" "AWSBackupOperatorPolicy" {
  name       = "AWSBackupOperatorPolicy"
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupOperatorPolicy"
}

resource "aws_iam_policy_attachment" "AWSBackupServiceRolePolicyForBackup" {
  name       = "AWSBackupServiceRolePolicyForBackup"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_policy_attachment" "AWSBackupServiceRolePolicyForRestores" {
  name       = "AWSBackupServiceRolePolicyForRestores"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_iam_policy_attachment" "AWSBatchFullAccess" {
  name       = "AWSBatchFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSBatchFullAccess"
}

resource "aws_iam_policy_attachment" "AWSBatchServiceEventTargetRole" {
  name       = "AWSBatchServiceEventTargetRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceEventTargetRole"
}

resource "aws_iam_policy_attachment" "AWSBatchServiceRole" {
  name       = "AWSBatchServiceRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_iam_policy_attachment" "AWSCertificateManagerFullAccess" {
  name       = "AWSCertificateManagerFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCertificateManagerFullAccess"
}

resource "aws_iam_policy_attachment" "AWSCertificateManagerPrivateCAAuditor" {
  name       = "AWSCertificateManagerPrivateCAAuditor"
  policy_arn = "arn:aws:iam::aws:policy/AWSCertificateManagerPrivateCAAuditor"
}

resource "aws_iam_policy_attachment" "AWSCertificateManagerPrivateCAFullAccess" {
  name       = "AWSCertificateManagerPrivateCAFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCertificateManagerPrivateCAFullAccess"
}

resource "aws_iam_policy_attachment" "AWSCertificateManagerPrivateCAReadOnly" {
  name       = "AWSCertificateManagerPrivateCAReadOnly"
  policy_arn = "arn:aws:iam::aws:policy/AWSCertificateManagerPrivateCAReadOnly"
}

resource "aws_iam_policy_attachment" "AWSCertificateManagerPrivateCAUser" {
  name       = "AWSCertificateManagerPrivateCAUser"
  policy_arn = "arn:aws:iam::aws:policy/AWSCertificateManagerPrivateCAUser"
}

resource "aws_iam_policy_attachment" "AWSCertificateManagerReadOnly" {
  name       = "AWSCertificateManagerReadOnly"
  policy_arn = "arn:aws:iam::aws:policy/AWSCertificateManagerReadOnly"
}

resource "aws_iam_policy_attachment" "AWSCloud9Administrator" {
  name       = "AWSCloud9Administrator"
  policy_arn = "arn:aws:iam::aws:policy/AWSCloud9Administrator"
}

resource "aws_iam_policy_attachment" "AWSCloud9EnvironmentMember" {
  name       = "AWSCloud9EnvironmentMember"
  policy_arn = "arn:aws:iam::aws:policy/AWSCloud9EnvironmentMember"
}

resource "aws_iam_policy_attachment" "AWSCloud9ServiceRolePolicy" {
  name       = "AWSCloud9ServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSCloud9ServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AWSCloud9User" {
  name       = "AWSCloud9User"
  policy_arn = "arn:aws:iam::aws:policy/AWSCloud9User"
}

resource "aws_iam_policy_attachment" "AWSCloudFormationReadOnlyAccess" {
  name       = "AWSCloudFormationReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudFormationReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSCloudFrontLogger" {
  name       = "AWSCloudFrontLogger"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSCloudFrontLogger"
}

resource "aws_iam_policy_attachment" "AWSCloudHSMFullAccess" {
  name       = "AWSCloudHSMFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudHSMFullAccess"
}

resource "aws_iam_policy_attachment" "AWSCloudHSMReadOnlyAccess" {
  name       = "AWSCloudHSMReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudHSMReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSCloudHSMRole" {
  name       = "AWSCloudHSMRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCloudHSMRole"
}

resource "aws_iam_policy_attachment" "AWSCloudMapDiscoverInstanceAccess" {
  name       = "AWSCloudMapDiscoverInstanceAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudMapDiscoverInstanceAccess"
}

resource "aws_iam_policy_attachment" "AWSCloudMapFullAccess" {
  name       = "AWSCloudMapFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudMapFullAccess"
}

resource "aws_iam_policy_attachment" "AWSCloudMapReadOnlyAccess" {
  name       = "AWSCloudMapReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudMapReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSCloudMapRegisterInstanceAccess" {
  name       = "AWSCloudMapRegisterInstanceAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudMapRegisterInstanceAccess"
}

resource "aws_iam_policy_attachment" "AWSCloudTrailFullAccess" {
  name       = "AWSCloudTrailFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudTrailFullAccess"
}

resource "aws_iam_policy_attachment" "AWSCloudTrailReadOnlyAccess" {
  name       = "AWSCloudTrailReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudTrailReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSCodeBuildAdminAccess" {
  name       = "AWSCodeBuildAdminAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

resource "aws_iam_policy_attachment" "AWSCodeBuildDeveloperAccess" {
  name       = "AWSCodeBuildDeveloperAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

resource "aws_iam_policy_attachment" "AWSCodeBuildReadOnlyAccess" {
  name       = "AWSCodeBuildReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSCodeCommitFullAccess" {
  name       = "AWSCodeCommitFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess"
}

resource "aws_iam_policy_attachment" "AWSCodeCommitPowerUser" {
  name       = "AWSCodeCommitPowerUser"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitPowerUser"
}

resource "aws_iam_policy_attachment" "AWSCodeCommitReadOnly" {
  name       = "AWSCodeCommitReadOnly"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitReadOnly"
}

resource "aws_iam_policy_attachment" "AWSCodeDeployDeployerAccess" {
  name       = "AWSCodeDeployDeployerAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployDeployerAccess"
}

resource "aws_iam_policy_attachment" "AWSCodeDeployFullAccess" {
  name       = "AWSCodeDeployFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
}

resource "aws_iam_policy_attachment" "AWSCodeDeployReadOnlyAccess" {
  name       = "AWSCodeDeployReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSCodeDeployRole" {
  name       = "AWSCodeDeployRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_iam_policy_attachment" "AWSCodeDeployRoleForECS" {
  name       = "AWSCodeDeployRoleForECS"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

resource "aws_iam_policy_attachment" "AWSCodeDeployRoleForECSLimited" {
  name       = "AWSCodeDeployRoleForECSLimited"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECSLimited"
}

resource "aws_iam_policy_attachment" "AWSCodeDeployRoleForLambda" {
  name       = "AWSCodeDeployRoleForLambda"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRoleForLambda"
}

resource "aws_iam_policy_attachment" "AWSCodePipelineApproverAccess" {
  name       = "AWSCodePipelineApproverAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipelineApproverAccess"
}

resource "aws_iam_policy_attachment" "AWSCodePipelineCustomActionAccess" {
  name       = "AWSCodePipelineCustomActionAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipelineCustomActionAccess"
}

resource "aws_iam_policy_attachment" "AWSCodePipelineFullAccess" {
  name       = "AWSCodePipelineFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipelineFullAccess"
}

resource "aws_iam_policy_attachment" "AWSCodePipelineReadOnlyAccess" {
  name       = "AWSCodePipelineReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipelineReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSCodeStarFullAccess" {
  name       = "AWSCodeStarFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeStarFullAccess"
}

resource "aws_iam_policy_attachment" "AWSCodeStarServiceRole" {
  name       = "AWSCodeStarServiceRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeStarServiceRole"
}

resource "aws_iam_policy_attachment" "AWSConfigRole" {
  name       = "AWSConfigRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

resource "aws_iam_policy_attachment" "AWSConfigRoleForOrganizations" {
  name       = "AWSConfigRoleForOrganizations"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}

resource "aws_iam_policy_attachment" "AWSConfigRulesExecutionRole" {
  name       = "AWSConfigRulesExecutionRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRulesExecutionRole"
}

resource "aws_iam_policy_attachment" "AWSConfigServiceRolePolicy" {
  name       = "AWSConfigServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSConfigServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AWSConfigUserAccess" {
  name       = "AWSConfigUserAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSConfigUserAccess"
}

resource "aws_iam_policy_attachment" "AWSConnector" {
  name       = "AWSConnector"
  policy_arn = "arn:aws:iam::aws:policy/AWSConnector"
}

resource "aws_iam_policy_attachment" "AWSControlTowerServiceRolePolicy" {
  name       = "AWSControlTowerServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSControlTowerServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AWSDataLifecycleManagerServiceRole" {
  name       = "AWSDataLifecycleManagerServiceRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSDataLifecycleManagerServiceRole"
}

resource "aws_iam_policy_attachment" "AWSDataPipelineRole" {
  name       = "AWSDataPipelineRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSDataPipelineRole"
}

resource "aws_iam_policy_attachment" "AWSDataPipeline_FullAccess" {
  name       = "AWSDataPipeline_FullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSDataPipeline_FullAccess"
}

resource "aws_iam_policy_attachment" "AWSDataPipeline_PowerUser" {
  name       = "AWSDataPipeline_PowerUser"
  policy_arn = "arn:aws:iam::aws:policy/AWSDataPipeline_PowerUser"
}

resource "aws_iam_policy_attachment" "AWSDataSyncFullAccess" {
  name       = "AWSDataSyncFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSDataSyncFullAccess"
}

resource "aws_iam_policy_attachment" "AWSDataSyncReadOnlyAccess" {
  name       = "AWSDataSyncReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSDataSyncReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSDeepLensLambdaFunctionAccessPolicy" {
  name       = "AWSDeepLensLambdaFunctionAccessPolicy"
  policy_arn = "arn:aws:iam::aws:policy/AWSDeepLensLambdaFunctionAccessPolicy"
}

resource "aws_iam_policy_attachment" "AWSDeepLensServiceRolePolicy" {
  name       = "AWSDeepLensServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSDeepLensServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AWSDeepRacerCloudFormationAccessPolicy" {
  name       = "AWSDeepRacerCloudFormationAccessPolicy"
  policy_arn = "arn:aws:iam::aws:policy/AWSDeepRacerCloudFormationAccessPolicy"
}

resource "aws_iam_policy_attachment" "AWSDeepRacerRoboMakerAccessPolicy" {
  name       = "AWSDeepRacerRoboMakerAccessPolicy"
  policy_arn = "arn:aws:iam::aws:policy/AWSDeepRacerRoboMakerAccessPolicy"
}

resource "aws_iam_policy_attachment" "AWSDeepRacerServiceRolePolicy" {
  name       = "AWSDeepRacerServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSDeepRacerServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AWSDenyAll" {
  name       = "AWSDenyAll"
  policy_arn = "arn:aws:iam::aws:policy/AWSDenyAll"
}

resource "aws_iam_policy_attachment" "AWSDeviceFarmFullAccess" {
  name       = "AWSDeviceFarmFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSDeviceFarmFullAccess"
}

resource "aws_iam_policy_attachment" "AWSDirectConnectFullAccess" {
  name       = "AWSDirectConnectFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSDirectConnectFullAccess"
}

resource "aws_iam_policy_attachment" "AWSDirectConnectReadOnlyAccess" {
  name       = "AWSDirectConnectReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSDirectConnectReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSDirectoryServiceFullAccess" {
  name       = "AWSDirectoryServiceFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSDirectoryServiceFullAccess"
}

resource "aws_iam_policy_attachment" "AWSDirectoryServiceReadOnlyAccess" {
  name       = "AWSDirectoryServiceReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSDirectoryServiceReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSDiscoveryContinuousExportFirehosePolicy" {
  name       = "AWSDiscoveryContinuousExportFirehosePolicy"
  policy_arn = "arn:aws:iam::aws:policy/AWSDiscoveryContinuousExportFirehosePolicy"
}

resource "aws_iam_policy_attachment" "AWSEC2FleetServiceRolePolicy" {
  name       = "AWSEC2FleetServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSEC2FleetServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AWSEC2SpotFleetServiceRolePolicy" {
  name       = "AWSEC2SpotFleetServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSEC2SpotFleetServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AWSEC2SpotServiceRolePolicy" {
  name       = "AWSEC2SpotServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSEC2SpotServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AWSElasticBeanstalkCustomPlatformforEC2Role" {
  name       = "AWSElasticBeanstalkCustomPlatformforEC2Role"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkCustomPlatformforEC2Role"
}

resource "aws_iam_policy_attachment" "AWSElasticBeanstalkEnhancedHealth" {
  name       = "AWSElasticBeanstalkEnhancedHealth"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_policy_attachment" "AWSElasticBeanstalkFullAccess" {
  name       = "AWSElasticBeanstalkFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkFullAccess"
}

resource "aws_iam_policy_attachment" "AWSElasticBeanstalkMaintenance" {
  name       = "AWSElasticBeanstalkMaintenance"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSElasticBeanstalkMaintenance"
}

resource "aws_iam_policy_attachment" "AWSElasticBeanstalkMulticontainerDocker" {
  name       = "AWSElasticBeanstalkMulticontainerDocker"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_policy_attachment" "AWSElasticBeanstalkReadOnlyAccess" {
  name       = "AWSElasticBeanstalkReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSElasticBeanstalkService" {
  name       = "AWSElasticBeanstalkService"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

resource "aws_iam_policy_attachment" "AWSElasticBeanstalkServiceRolePolicy" {
  name       = "AWSElasticBeanstalkServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSElasticBeanstalkServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AWSElasticBeanstalkWebTier" {
  name       = "AWSElasticBeanstalkWebTier"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_policy_attachment" "AWSElasticBeanstalkWorkerTier" {
  name       = "AWSElasticBeanstalkWorkerTier"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_policy_attachment" "AWSElasticLoadBalancingClassicServiceRolePolicy" {
  name       = "AWSElasticLoadBalancingClassicServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSElasticLoadBalancingClassicServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AWSElasticLoadBalancingServiceRolePolicy" {
  name       = "AWSElasticLoadBalancingServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSElasticLoadBalancingServiceRolePolicy"
  roles      = ["AWSServiceRoleForElasticLoadBalancing"]
}

resource "aws_iam_policy_attachment" "AWSElementalMediaConvertFullAccess" {
  name       = "AWSElementalMediaConvertFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSElementalMediaConvertFullAccess"
}

resource "aws_iam_policy_attachment" "AWSElementalMediaConvertReadOnly" {
  name       = "AWSElementalMediaConvertReadOnly"
  policy_arn = "arn:aws:iam::aws:policy/AWSElementalMediaConvertReadOnly"
}

resource "aws_iam_policy_attachment" "AWSElementalMediaPackageFullAccess" {
  name       = "AWSElementalMediaPackageFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSElementalMediaPackageFullAccess"
}

resource "aws_iam_policy_attachment" "AWSElementalMediaPackageReadOnly" {
  name       = "AWSElementalMediaPackageReadOnly"
  policy_arn = "arn:aws:iam::aws:policy/AWSElementalMediaPackageReadOnly"
}

resource "aws_iam_policy_attachment" "AWSElementalMediaStoreFullAccess" {
  name       = "AWSElementalMediaStoreFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSElementalMediaStoreFullAccess"
}

resource "aws_iam_policy_attachment" "AWSElementalMediaStoreReadOnly" {
  name       = "AWSElementalMediaStoreReadOnly"
  policy_arn = "arn:aws:iam::aws:policy/AWSElementalMediaStoreReadOnly"
}

resource "aws_iam_policy_attachment" "AWSEnhancedClassicNetworkingMangementPolicy" {
  name       = "AWSEnhancedClassicNetworkingMangementPolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSEnhancedClassicNetworkingMangementPolicy"
}

resource "aws_iam_policy_attachment" "AWSFMAdminFullAccess" {
  name       = "AWSFMAdminFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSFMAdminFullAccess"
}

resource "aws_iam_policy_attachment" "AWSFMAdminReadOnlyAccess" {
  name       = "AWSFMAdminReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSFMAdminReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSFMMemberReadOnlyAccess" {
  name       = "AWSFMMemberReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSFMMemberReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSGlobalAcceleratorSLRPolicy" {
  name       = "AWSGlobalAcceleratorSLRPolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSGlobalAcceleratorSLRPolicy"
}

resource "aws_iam_policy_attachment" "AWSGlueConsoleFullAccess" {
  name       = "AWSGlueConsoleFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}

resource "aws_iam_policy_attachment" "AWSGlueConsoleSageMakerNotebookFullAccess" {
  name       = "AWSGlueConsoleSageMakerNotebookFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleSageMakerNotebookFullAccess"
}

resource "aws_iam_policy_attachment" "AWSGlueServiceNotebookRole" {
  name       = "AWSGlueServiceNotebookRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceNotebookRole"
}

resource "aws_iam_policy_attachment" "AWSGlueServiceRole" {
  name       = "AWSGlueServiceRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_policy_attachment" "AWSGreengrassFullAccess" {
  name       = "AWSGreengrassFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSGreengrassFullAccess"
}

resource "aws_iam_policy_attachment" "AWSGreengrassReadOnlyAccess" {
  name       = "AWSGreengrassReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSGreengrassReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSGreengrassResourceAccessRolePolicy" {
  name       = "AWSGreengrassResourceAccessRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGreengrassResourceAccessRolePolicy"
}

resource "aws_iam_policy_attachment" "AWSHealthFullAccess" {
  name       = "AWSHealthFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSHealthFullAccess"
}

resource "aws_iam_policy_attachment" "AWSIQFullAccess" {
  name       = "AWSIQFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSIQFullAccess"
}

resource "aws_iam_policy_attachment" "AWSImportExportFullAccess" {
  name       = "AWSImportExportFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSImportExportFullAccess"
}

resource "aws_iam_policy_attachment" "AWSImportExportReadOnlyAccess" {
  name       = "AWSImportExportReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSImportExportReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSIoT1ClickFullAccess" {
  name       = "AWSIoT1ClickFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSIoT1ClickFullAccess"
}

resource "aws_iam_policy_attachment" "AWSIoT1ClickReadOnlyAccess" {
  name       = "AWSIoT1ClickReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSIoT1ClickReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSIoTAnalyticsFullAccess" {
  name       = "AWSIoTAnalyticsFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSIoTAnalyticsFullAccess"
}

resource "aws_iam_policy_attachment" "AWSIoTAnalyticsReadOnlyAccess" {
  name       = "AWSIoTAnalyticsReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSIoTAnalyticsReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSIoTConfigAccess" {
  name       = "AWSIoTConfigAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSIoTConfigAccess"
}

resource "aws_iam_policy_attachment" "AWSIoTConfigReadOnlyAccess" {
  name       = "AWSIoTConfigReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSIoTConfigReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSIoTDataAccess" {
  name       = "AWSIoTDataAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSIoTDataAccess"
}

resource "aws_iam_policy_attachment" "AWSIoTDeviceDefenderAudit" {
  name       = "AWSIoTDeviceDefenderAudit"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSIoTDeviceDefenderAudit"
}

resource "aws_iam_policy_attachment" "AWSIoTEventsFullAccess" {
  name       = "AWSIoTEventsFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSIoTEventsFullAccess"
}

resource "aws_iam_policy_attachment" "AWSIoTEventsReadOnlyAccess" {
  name       = "AWSIoTEventsReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSIoTEventsReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSIoTFullAccess" {
  name       = "AWSIoTFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSIoTFullAccess"
}

resource "aws_iam_policy_attachment" "AWSIoTLogging" {
  name       = "AWSIoTLogging"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSIoTLogging"
}

resource "aws_iam_policy_attachment" "AWSIoTOTAUpdate" {
  name       = "AWSIoTOTAUpdate"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSIoTOTAUpdate"
}

resource "aws_iam_policy_attachment" "AWSIoTRuleActions" {
  name       = "AWSIoTRuleActions"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSIoTRuleActions"
}

resource "aws_iam_policy_attachment" "AWSIoTSiteWiseFullAccess" {
  name       = "AWSIoTSiteWiseFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSIoTSiteWiseFullAccess"
}

resource "aws_iam_policy_attachment" "AWSIoTSiteWiseReadOnlyAccess" {
  name       = "AWSIoTSiteWiseReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSIoTSiteWiseReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSIoTThingsRegistration" {
  name       = "AWSIoTThingsRegistration"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSIoTThingsRegistration"
}

resource "aws_iam_policy_attachment" "AWSKeyManagementServiceCustomKeyStoresServiceRolePolicy" {
  name       = "AWSKeyManagementServiceCustomKeyStoresServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSKeyManagementServiceCustomKeyStoresServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AWSKeyManagementServicePowerUser" {
  name       = "AWSKeyManagementServicePowerUser"
  policy_arn = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
}

resource "aws_iam_policy_attachment" "AWSLambdaBasicExecutionRole" {
  name       = "AWSLambdaBasicExecutionRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy_attachment" "AWSLambdaDynamoDBExecutionRole" {
  name       = "AWSLambdaDynamoDBExecutionRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole"
}

resource "aws_iam_policy_attachment" "AWSLambdaENIManagementAccess" {
  name       = "AWSLambdaENIManagementAccess"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaENIManagementAccess"
}

resource "aws_iam_policy_attachment" "AWSLambdaExecute" {
  name       = "AWSLambdaExecute"
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}

resource "aws_iam_policy_attachment" "AWSLambdaFullAccess" {
  name       = "AWSLambdaFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaFullAccess"
}

resource "aws_iam_policy_attachment" "AWSLambdaInvocation-DynamoDB" {
  name       = "AWSLambdaInvocation-DynamoDB"
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaInvocation-DynamoDB"
}

resource "aws_iam_policy_attachment" "AWSLambdaKinesisExecutionRole" {
  name       = "AWSLambdaKinesisExecutionRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole"
}

resource "aws_iam_policy_attachment" "AWSLambdaReadOnlyAccess" {
  name       = "AWSLambdaReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSLambdaReplicator" {
  name       = "AWSLambdaReplicator"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSLambdaReplicator"
}

resource "aws_iam_policy_attachment" "AWSLambdaRole" {
  name       = "AWSLambdaRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
}

resource "aws_iam_policy_attachment" "AWSLambdaSQSQueueExecutionRole" {
  name       = "AWSLambdaSQSQueueExecutionRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_iam_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
  name       = "AWSLambdaVPCAccessExecutionRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy_attachment" "AWSLicenseManagerMasterAccountRolePolicy" {
  name       = "AWSLicenseManagerMasterAccountRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSLicenseManagerMasterAccountRolePolicy"
}

resource "aws_iam_policy_attachment" "AWSLicenseManagerMemberAccountRolePolicy" {
  name       = "AWSLicenseManagerMemberAccountRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSLicenseManagerMemberAccountRolePolicy"
}

resource "aws_iam_policy_attachment" "AWSLicenseManagerServiceRolePolicy" {
  name       = "AWSLicenseManagerServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSLicenseManagerServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AWSMarketplaceFullAccess" {
  name       = "AWSMarketplaceFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSMarketplaceFullAccess"
}

resource "aws_iam_policy_attachment" "AWSMarketplaceGetEntitlements" {
  name       = "AWSMarketplaceGetEntitlements"
  policy_arn = "arn:aws:iam::aws:policy/AWSMarketplaceGetEntitlements"
}

resource "aws_iam_policy_attachment" "AWSMarketplaceImageBuildFullAccess" {
  name       = "AWSMarketplaceImageBuildFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSMarketplaceImageBuildFullAccess"
}

resource "aws_iam_policy_attachment" "AWSMarketplaceManageSubscriptions" {
  name       = "AWSMarketplaceManageSubscriptions"
  policy_arn = "arn:aws:iam::aws:policy/AWSMarketplaceManageSubscriptions"
}

resource "aws_iam_policy_attachment" "AWSMarketplaceMeteringFullAccess" {
  name       = "AWSMarketplaceMeteringFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSMarketplaceMeteringFullAccess"
}

resource "aws_iam_policy_attachment" "AWSMarketplaceRead-only" {
  name       = "AWSMarketplaceRead-only"
  policy_arn = "arn:aws:iam::aws:policy/AWSMarketplaceRead-only"
}

resource "aws_iam_policy_attachment" "AWSMigrationHubDMSAccess" {
  name       = "AWSMigrationHubDMSAccess"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSMigrationHubDMSAccess"
}

resource "aws_iam_policy_attachment" "AWSMigrationHubDiscoveryAccess" {
  name       = "AWSMigrationHubDiscoveryAccess"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSMigrationHubDiscoveryAccess"
}

resource "aws_iam_policy_attachment" "AWSMigrationHubFullAccess" {
  name       = "AWSMigrationHubFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSMigrationHubFullAccess"
}

resource "aws_iam_policy_attachment" "AWSMigrationHubSMSAccess" {
  name       = "AWSMigrationHubSMSAccess"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSMigrationHubSMSAccess"
}

resource "aws_iam_policy_attachment" "AWSMobileHub_FullAccess" {
  name       = "AWSMobileHub_FullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSMobileHub_FullAccess"
}

resource "aws_iam_policy_attachment" "AWSMobileHub_ReadOnly" {
  name       = "AWSMobileHub_ReadOnly"
  policy_arn = "arn:aws:iam::aws:policy/AWSMobileHub_ReadOnly"
}

resource "aws_iam_policy_attachment" "AWSOpsWorksCMInstanceProfileRole" {
  name       = "AWSOpsWorksCMInstanceProfileRole"
  policy_arn = "arn:aws:iam::aws:policy/AWSOpsWorksCMInstanceProfileRole"
}

resource "aws_iam_policy_attachment" "AWSOpsWorksCMServiceRole" {
  name       = "AWSOpsWorksCMServiceRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSOpsWorksCMServiceRole"
}

resource "aws_iam_policy_attachment" "AWSOpsWorksCloudWatchLogs" {
  name       = "AWSOpsWorksCloudWatchLogs"
  policy_arn = "arn:aws:iam::aws:policy/AWSOpsWorksCloudWatchLogs"
}

resource "aws_iam_policy_attachment" "AWSOpsWorksFullAccess" {
  name       = "AWSOpsWorksFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSOpsWorksFullAccess"
}

resource "aws_iam_policy_attachment" "AWSOpsWorksInstanceRegistration" {
  name       = "AWSOpsWorksInstanceRegistration"
  policy_arn = "arn:aws:iam::aws:policy/AWSOpsWorksInstanceRegistration"
}

resource "aws_iam_policy_attachment" "AWSOpsWorksRegisterCLI" {
  name       = "AWSOpsWorksRegisterCLI"
  policy_arn = "arn:aws:iam::aws:policy/AWSOpsWorksRegisterCLI"
}

resource "aws_iam_policy_attachment" "AWSOpsWorksRole" {
  name       = "AWSOpsWorksRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSOpsWorksRole"
}

resource "aws_iam_policy_attachment" "AWSOrganizationsFullAccess" {
  name       = "AWSOrganizationsFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSOrganizationsFullAccess"
}

resource "aws_iam_policy_attachment" "AWSOrganizationsReadOnlyAccess" {
  name       = "AWSOrganizationsReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSOrganizationsReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSOrganizationsServiceTrustPolicy" {
  name       = "AWSOrganizationsServiceTrustPolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSOrganizationsServiceTrustPolicy"
}

resource "aws_iam_policy_attachment" "AWSPriceListServiceFullAccess" {
  name       = "AWSPriceListServiceFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSPriceListServiceFullAccess"
}

resource "aws_iam_policy_attachment" "AWSPrivateMarketplaceAdminFullAccess" {
  name       = "AWSPrivateMarketplaceAdminFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSPrivateMarketplaceAdminFullAccess"
}

resource "aws_iam_policy_attachment" "AWSQuickSightDescribeRDS" {
  name       = "AWSQuickSightDescribeRDS"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSQuickSightDescribeRDS"
}

resource "aws_iam_policy_attachment" "AWSQuickSightDescribeRedshift" {
  name       = "AWSQuickSightDescribeRedshift"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSQuickSightDescribeRedshift"
}

resource "aws_iam_policy_attachment" "AWSQuickSightIoTAnalyticsAccess" {
  name       = "AWSQuickSightIoTAnalyticsAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSQuickSightIoTAnalyticsAccess"
}

resource "aws_iam_policy_attachment" "AWSQuickSightListIAM" {
  name       = "AWSQuickSightListIAM"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSQuickSightListIAM"
}

resource "aws_iam_policy_attachment" "AWSQuicksightAthenaAccess" {
  name       = "AWSQuicksightAthenaAccess"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSQuicksightAthenaAccess"
}

resource "aws_iam_policy_attachment" "AWSResourceAccessManagerServiceRolePolicy" {
  name       = "AWSResourceAccessManagerServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSResourceAccessManagerServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AWSResourceGroupsReadOnlyAccess" {
  name       = "AWSResourceGroupsReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSResourceGroupsReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSRoboMakerFullAccess" {
  name       = "AWSRoboMakerFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSRoboMakerFullAccess"
}

resource "aws_iam_policy_attachment" "AWSRoboMakerReadOnlyAccess" {
  name       = "AWSRoboMakerReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSRoboMakerReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSRoboMakerServicePolicy" {
  name       = "AWSRoboMakerServicePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSRoboMakerServicePolicy"
}

resource "aws_iam_policy_attachment" "AWSRoboMakerServiceRolePolicy" {
  name       = "AWSRoboMakerServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/AWSRoboMakerServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AWSSSODirectoryAdministrator" {
  name       = "AWSSSODirectoryAdministrator"
  policy_arn = "arn:aws:iam::aws:policy/AWSSSODirectoryAdministrator"
}

resource "aws_iam_policy_attachment" "AWSSSODirectoryReadOnly" {
  name       = "AWSSSODirectoryReadOnly"
  policy_arn = "arn:aws:iam::aws:policy/AWSSSODirectoryReadOnly"
}

resource "aws_iam_policy_attachment" "AWSSSOMasterAccountAdministrator" {
  name       = "AWSSSOMasterAccountAdministrator"
  policy_arn = "arn:aws:iam::aws:policy/AWSSSOMasterAccountAdministrator"
}

resource "aws_iam_policy_attachment" "AWSSSOMemberAccountAdministrator" {
  name       = "AWSSSOMemberAccountAdministrator"
  policy_arn = "arn:aws:iam::aws:policy/AWSSSOMemberAccountAdministrator"
}

resource "aws_iam_policy_attachment" "AWSSSOReadOnly" {
  name       = "AWSSSOReadOnly"
  policy_arn = "arn:aws:iam::aws:policy/AWSSSOReadOnly"
}

resource "aws_iam_policy_attachment" "AWSSSOServiceRolePolicy" {
  name       = "AWSSSOServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSSSOServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AWSSecurityHubFullAccess" {
  name       = "AWSSecurityHubFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSSecurityHubFullAccess"
}

resource "aws_iam_policy_attachment" "AWSSecurityHubReadOnlyAccess" {
  name       = "AWSSecurityHubReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSSecurityHubReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSSecurityHubServiceRolePolicy" {
  name       = "AWSSecurityHubServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSSecurityHubServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AWSServiceCatalogAdminFullAccess" {
  name       = "AWSServiceCatalogAdminFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSServiceCatalogAdminFullAccess"
}

resource "aws_iam_policy_attachment" "AWSServiceCatalogEndUserFullAccess" {
  name       = "AWSServiceCatalogEndUserFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSServiceCatalogEndUserFullAccess"
}

resource "aws_iam_policy_attachment" "AWSServiceRoleForEC2ScheduledInstances" {
  name       = "AWSServiceRoleForEC2ScheduledInstances"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSServiceRoleForEC2ScheduledInstances"
}

resource "aws_iam_policy_attachment" "AWSServiceRoleForIoTSiteWise" {
  name       = "AWSServiceRoleForIoTSiteWise"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSServiceRoleForIoTSiteWise"
}

resource "aws_iam_policy_attachment" "AWSShieldDRTAccessPolicy" {
  name       = "AWSShieldDRTAccessPolicy"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSShieldDRTAccessPolicy"
}

resource "aws_iam_policy_attachment" "AWSStepFunctionsConsoleFullAccess" {
  name       = "AWSStepFunctionsConsoleFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsConsoleFullAccess"
}

resource "aws_iam_policy_attachment" "AWSStepFunctionsFullAccess" {
  name       = "AWSStepFunctionsFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess"
}

resource "aws_iam_policy_attachment" "AWSStepFunctionsReadOnlyAccess" {
  name       = "AWSStepFunctionsReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSStorageGatewayFullAccess" {
  name       = "AWSStorageGatewayFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSStorageGatewayFullAccess"
}

resource "aws_iam_policy_attachment" "AWSStorageGatewayReadOnlyAccess" {
  name       = "AWSStorageGatewayReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSStorageGatewayReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSSupportAccess" {
  name       = "AWSSupportAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSSupportAccess"
}

resource "aws_iam_policy_attachment" "AWSSupportServiceRolePolicy" {
  name       = "AWSSupportServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSSupportServiceRolePolicy"
  roles      = ["AWSServiceRoleForSupport"]
}

resource "aws_iam_policy_attachment" "AWSTransferLoggingAccess" {
  name       = "AWSTransferLoggingAccess"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSTransferLoggingAccess"
}

resource "aws_iam_policy_attachment" "AWSTrustedAdvisorServiceRolePolicy" {
  name       = "AWSTrustedAdvisorServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSTrustedAdvisorServiceRolePolicy"
  roles      = ["AWSServiceRoleForTrustedAdvisor"]
}

resource "aws_iam_policy_attachment" "AWSVPCTransitGatewayServiceRolePolicy" {
  name       = "AWSVPCTransitGatewayServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSVPCTransitGatewayServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AWSWAFFullAccess" {
  name       = "AWSWAFFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSWAFFullAccess"
}

resource "aws_iam_policy_attachment" "AWSWAFReadOnlyAccess" {
  name       = "AWSWAFReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSWAFReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSXRayDaemonWriteAccess" {
  name       = "AWSXRayDaemonWriteAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_policy_attachment" "AWSXrayFullAccess" {
  name       = "AWSXrayFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayFullAccess"
}

resource "aws_iam_policy_attachment" "AWSXrayReadOnlyAccess" {
  name       = "AWSXrayReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AWSXrayWriteOnlyAccess" {
  name       = "AWSXrayWriteOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

resource "aws_iam_policy_attachment" "AdministratorAccess" {
  groups     = ["Admin"]
  name       = "AdministratorAccess"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_policy_attachment" "AlexaForBusinessDeviceSetup" {
  name       = "AlexaForBusinessDeviceSetup"
  policy_arn = "arn:aws:iam::aws:policy/AlexaForBusinessDeviceSetup"
}

resource "aws_iam_policy_attachment" "AlexaForBusinessFullAccess" {
  name       = "AlexaForBusinessFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AlexaForBusinessFullAccess"
}

resource "aws_iam_policy_attachment" "AlexaForBusinessGatewayExecution" {
  name       = "AlexaForBusinessGatewayExecution"
  policy_arn = "arn:aws:iam::aws:policy/AlexaForBusinessGatewayExecution"
}

resource "aws_iam_policy_attachment" "AlexaForBusinessNetworkProfileServicePolicy" {
  name       = "AlexaForBusinessNetworkProfileServicePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AlexaForBusinessNetworkProfileServicePolicy"
}

resource "aws_iam_policy_attachment" "AlexaForBusinessReadOnlyAccess" {
  name       = "AlexaForBusinessReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AlexaForBusinessReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonAPIGatewayAdministrator" {
  name       = "AmazonAPIGatewayAdministrator"
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator"
}

resource "aws_iam_policy_attachment" "AmazonAPIGatewayInvokeFullAccess" {
  name       = "AmazonAPIGatewayInvokeFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonAPIGatewayPushToCloudWatchLogs" {
  name       = "AmazonAPIGatewayPushToCloudWatchLogs"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_iam_policy_attachment" "AmazonAppStreamFullAccess" {
  name       = "AmazonAppStreamFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonAppStreamFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonAppStreamReadOnlyAccess" {
  name       = "AmazonAppStreamReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonAppStreamReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonAppStreamServiceAccess" {
  name       = "AmazonAppStreamServiceAccess"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAppStreamServiceAccess"
}

resource "aws_iam_policy_attachment" "AmazonAthenaFullAccess" {
  name       = "AmazonAthenaFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonChimeFullAccess" {
  name       = "AmazonChimeFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonChimeFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonChimeReadOnly" {
  name       = "AmazonChimeReadOnly"
  policy_arn = "arn:aws:iam::aws:policy/AmazonChimeReadOnly"
}

resource "aws_iam_policy_attachment" "AmazonChimeUserManagement" {
  name       = "AmazonChimeUserManagement"
  policy_arn = "arn:aws:iam::aws:policy/AmazonChimeUserManagement"
}

resource "aws_iam_policy_attachment" "AmazonCloudDirectoryFullAccess" {
  name       = "AmazonCloudDirectoryFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonCloudDirectoryFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonCloudDirectoryReadOnlyAccess" {
  name       = "AmazonCloudDirectoryReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonCloudDirectoryReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonCognitoDeveloperAuthenticatedIdentities" {
  name       = "AmazonCognitoDeveloperAuthenticatedIdentities"
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoDeveloperAuthenticatedIdentities"
}

resource "aws_iam_policy_attachment" "AmazonCognitoIdpEmailServiceRolePolicy" {
  name       = "AmazonCognitoIdpEmailServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonCognitoIdpEmailServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AmazonCognitoPowerUser" {
  name       = "AmazonCognitoPowerUser"
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
}

resource "aws_iam_policy_attachment" "AmazonCognitoReadOnly" {
  name       = "AmazonCognitoReadOnly"
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoReadOnly"
}

resource "aws_iam_policy_attachment" "AmazonConnectFullAccess" {
  name       = "AmazonConnectFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonConnectFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonConnectReadOnlyAccess" {
  name       = "AmazonConnectReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonConnectReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonConnectServiceLinkedRolePolicy" {
  name       = "AmazonConnectServiceLinkedRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonConnectServiceLinkedRolePolicy"
}

resource "aws_iam_policy_attachment" "AmazonDMSCloudWatchLogsRole" {
  name       = "AmazonDMSCloudWatchLogsRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
}

resource "aws_iam_policy_attachment" "AmazonDMSRedshiftS3Role" {
  name       = "AmazonDMSRedshiftS3Role"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role"
}

resource "aws_iam_policy_attachment" "AmazonDMSVPCManagementRole" {
  name       = "AmazonDMSVPCManagementRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

resource "aws_iam_policy_attachment" "AmazonDRSVPCManagement" {
  name       = "AmazonDRSVPCManagement"
  policy_arn = "arn:aws:iam::aws:policy/AmazonDRSVPCManagement"
}

resource "aws_iam_policy_attachment" "AmazonDocDBConsoleFullAccess" {
  name       = "AmazonDocDBConsoleFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonDocDBConsoleFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonDocDBFullAccess" {
  name       = "AmazonDocDBFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonDocDBFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonDocDBReadOnlyAccess" {
  name       = "AmazonDocDBReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonDocDBReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonDynamoDBFullAccess" {
  name       = "AmazonDynamoDBFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonDynamoDBFullAccesswithDataPipeline" {
  name       = "AmazonDynamoDBFullAccesswithDataPipeline"
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccesswithDataPipeline"
}

resource "aws_iam_policy_attachment" "AmazonDynamoDBReadOnlyAccess" {
  name       = "AmazonDynamoDBReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonEC2ContainerRegistryFullAccess" {
  name       = "AmazonEC2ContainerRegistryFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonEC2ContainerRegistryPowerUser" {
  name       = "AmazonEC2ContainerRegistryPowerUser"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  name       = "AmazonEC2ContainerRegistryReadOnly"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_policy_attachment" "AmazonEC2ContainerServiceAutoscaleRole" {
  name       = "AmazonEC2ContainerServiceAutoscaleRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

resource "aws_iam_policy_attachment" "AmazonEC2ContainerServiceEventsRole" {
  name       = "AmazonEC2ContainerServiceEventsRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}

resource "aws_iam_policy_attachment" "AmazonEC2ContainerServiceFullAccess" {
  name       = "AmazonEC2ContainerServiceFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerServiceFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonEC2ContainerServiceRole" {
  name       = "AmazonEC2ContainerServiceRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_policy_attachment" "AmazonEC2ContainerServiceforEC2Role" {
  name       = "AmazonEC2ContainerServiceforEC2Role"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_policy_attachment" "AmazonEC2FullAccess" {
  name       = "AmazonEC2FullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_policy_attachment" "AmazonEC2ReadOnlyAccess" {
  name       = "AmazonEC2ReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonEC2ReportsAccess" {
  name       = "AmazonEC2ReportsAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReportsAccess"
}

resource "aws_iam_policy_attachment" "AmazonEC2RoleforAWSCodeDeploy" {
  name       = "AmazonEC2RoleforAWSCodeDeploy"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_policy_attachment" "AmazonEC2RoleforDataPipelineRole" {
  name       = "AmazonEC2RoleforDataPipelineRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforDataPipelineRole"
}

resource "aws_iam_policy_attachment" "AmazonEC2RoleforSSM" {
  name       = "AmazonEC2RoleforSSM"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_policy_attachment" "AmazonEC2SpotFleetAutoscaleRole" {
  name       = "AmazonEC2SpotFleetAutoscaleRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetAutoscaleRole"
}

resource "aws_iam_policy_attachment" "AmazonEC2SpotFleetRole" {
  name       = "AmazonEC2SpotFleetRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole"
}

resource "aws_iam_policy_attachment" "AmazonEC2SpotFleetTaggingRole" {
  name       = "AmazonEC2SpotFleetTaggingRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}

resource "aws_iam_policy_attachment" "AmazonECSServiceRolePolicy" {
  name       = "AmazonECSServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonECSServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AmazonECSTaskExecutionRolePolicy" {
  name       = "AmazonECSTaskExecutionRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy_attachment" "AmazonECS_FullAccess" {
  name       = "AmazonECS_FullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_policy_attachment" "AmazonEKSClusterPolicy" {
  name       = "AmazonEKSClusterPolicy"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_policy_attachment" "AmazonEKSServicePolicy" {
  name       = "AmazonEKSServicePolicy"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  name       = "AmazonEKSWorkerNodePolicy"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_policy_attachment" "AmazonEKS_CNI_Policy" {
  name       = "AmazonEKS_CNI_Policy"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_policy_attachment" "AmazonEMRCleanupPolicy" {
  name       = "AmazonEMRCleanupPolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonEMRCleanupPolicy"
}

resource "aws_iam_policy_attachment" "AmazonESCognitoAccess" {
  name       = "AmazonESCognitoAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonESCognitoAccess"
}

resource "aws_iam_policy_attachment" "AmazonESFullAccess" {
  name       = "AmazonESFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonESFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonESReadOnlyAccess" {
  name       = "AmazonESReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonESReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonElastiCacheFullAccess" {
  name       = "AmazonElastiCacheFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonElastiCacheFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonElastiCacheReadOnlyAccess" {
  name       = "AmazonElastiCacheReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonElasticFileSystemFullAccess" {
  name       = "AmazonElasticFileSystemFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonElasticFileSystemReadOnlyAccess" {
  name       = "AmazonElasticFileSystemReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonElasticMapReduceEditorsRole" {
  name       = "AmazonElasticMapReduceEditorsRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceEditorsRole"
}

resource "aws_iam_policy_attachment" "AmazonElasticMapReduceFullAccess" {
  name       = "AmazonElasticMapReduceFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticMapReduceFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonElasticMapReduceReadOnlyAccess" {
  name       = "AmazonElasticMapReduceReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticMapReduceReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonElasticMapReduceRole" {
  name       = "AmazonElasticMapReduceRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

resource "aws_iam_policy_attachment" "AmazonElasticMapReduceforAutoScalingRole" {
  name       = "AmazonElasticMapReduceforAutoScalingRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforAutoScalingRole"
}

resource "aws_iam_policy_attachment" "AmazonElasticMapReduceforEC2Role" {
  name       = "AmazonElasticMapReduceforEC2Role"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

resource "aws_iam_policy_attachment" "AmazonElasticTranscoderRole" {
  name       = "AmazonElasticTranscoderRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticTranscoderRole"
}

resource "aws_iam_policy_attachment" "AmazonElasticTranscoder_FullAccess" {
  name       = "AmazonElasticTranscoder_FullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticTranscoder_FullAccess"
}

resource "aws_iam_policy_attachment" "AmazonElasticTranscoder_JobsSubmitter" {
  name       = "AmazonElasticTranscoder_JobsSubmitter"
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticTranscoder_JobsSubmitter"
}

resource "aws_iam_policy_attachment" "AmazonElasticTranscoder_ReadOnlyAccess" {
  name       = "AmazonElasticTranscoder_ReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticTranscoder_ReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonElasticsearchServiceRolePolicy" {
  name       = "AmazonElasticsearchServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonElasticsearchServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AmazonFSxConsoleFullAccess" {
  name       = "AmazonFSxConsoleFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonFSxConsoleFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonFSxConsoleReadOnlyAccess" {
  name       = "AmazonFSxConsoleReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonFSxConsoleReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonFSxFullAccess" {
  name       = "AmazonFSxFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonFSxFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonFSxReadOnlyAccess" {
  name       = "AmazonFSxReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonFSxReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonFSxServiceRolePolicy" {
  name       = "AmazonFSxServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonFSxServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AmazonForecastFullAccess" {
  name       = "AmazonForecastFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonForecastFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonFreeRTOSFullAccess" {
  name       = "AmazonFreeRTOSFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonFreeRTOSFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonFreeRTOSOTAUpdate" {
  name       = "AmazonFreeRTOSOTAUpdate"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonFreeRTOSOTAUpdate"
}

resource "aws_iam_policy_attachment" "AmazonGlacierFullAccess" {
  name       = "AmazonGlacierFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonGlacierFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonGlacierReadOnlyAccess" {
  name       = "AmazonGlacierReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonGlacierReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonGuardDutyFullAccess" {
  name       = "AmazonGuardDutyFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonGuardDutyFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonGuardDutyReadOnlyAccess" {
  name       = "AmazonGuardDutyReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonGuardDutyReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonGuardDutyServiceRolePolicy" {
  name       = "AmazonGuardDutyServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonGuardDutyServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AmazonInspectorFullAccess" {
  name       = "AmazonInspectorFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonInspectorFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonInspectorReadOnlyAccess" {
  name       = "AmazonInspectorReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonInspectorReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonInspectorServiceRolePolicy" {
  name       = "AmazonInspectorServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonInspectorServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AmazonKinesisAnalyticsFullAccess" {
  name       = "AmazonKinesisAnalyticsFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisAnalyticsFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonKinesisAnalyticsReadOnly" {
  name       = "AmazonKinesisAnalyticsReadOnly"
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisAnalyticsReadOnly"
}

resource "aws_iam_policy_attachment" "AmazonKinesisFirehoseFullAccess" {
  name       = "AmazonKinesisFirehoseFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFirehoseFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonKinesisFirehoseReadOnlyAccess" {
  name       = "AmazonKinesisFirehoseReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFirehoseReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonKinesisFullAccess" {
  name       = "AmazonKinesisFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonKinesisReadOnlyAccess" {
  name       = "AmazonKinesisReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonKinesisVideoStreamsFullAccess" {
  name       = "AmazonKinesisVideoStreamsFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisVideoStreamsFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonKinesisVideoStreamsReadOnlyAccess" {
  name       = "AmazonKinesisVideoStreamsReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisVideoStreamsReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonLexFullAccess" {
  name       = "AmazonLexFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonLexFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonLexReadOnly" {
  name       = "AmazonLexReadOnly"
  policy_arn = "arn:aws:iam::aws:policy/AmazonLexReadOnly"
}

resource "aws_iam_policy_attachment" "AmazonLexRunBotsOnly" {
  name       = "AmazonLexRunBotsOnly"
  policy_arn = "arn:aws:iam::aws:policy/AmazonLexRunBotsOnly"
}

resource "aws_iam_policy_attachment" "AmazonMQApiFullAccess" {
  name       = "AmazonMQApiFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMQApiFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonMQApiReadOnlyAccess" {
  name       = "AmazonMQApiReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMQApiReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonMQFullAccess" {
  name       = "AmazonMQFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMQFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonMQReadOnlyAccess" {
  name       = "AmazonMQReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMQReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonMSKFullAccess" {
  name       = "AmazonMSKFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMSKFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonMSKReadOnlyAccess" {
  name       = "AmazonMSKReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMSKReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonMachineLearningBatchPredictionsAccess" {
  name       = "AmazonMachineLearningBatchPredictionsAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMachineLearningBatchPredictionsAccess"
}

resource "aws_iam_policy_attachment" "AmazonMachineLearningCreateOnlyAccess" {
  name       = "AmazonMachineLearningCreateOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMachineLearningCreateOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonMachineLearningFullAccess" {
  name       = "AmazonMachineLearningFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMachineLearningFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonMachineLearningManageRealTimeEndpointOnlyAccess" {
  name       = "AmazonMachineLearningManageRealTimeEndpointOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMachineLearningManageRealTimeEndpointOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonMachineLearningReadOnlyAccess" {
  name       = "AmazonMachineLearningReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMachineLearningReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonMachineLearningRealTimePredictionOnlyAccess" {
  name       = "AmazonMachineLearningRealTimePredictionOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMachineLearningRealTimePredictionOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonMachineLearningRoleforRedshiftDataSource" {
  name       = "AmazonMachineLearningRoleforRedshiftDataSource"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonMachineLearningRoleforRedshiftDataSource"
}

resource "aws_iam_policy_attachment" "AmazonMacieFullAccess" {
  name       = "AmazonMacieFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMacieFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonMacieHandshakeRole" {
  name       = "AmazonMacieHandshakeRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonMacieHandshakeRole"
}

resource "aws_iam_policy_attachment" "AmazonMacieServiceRole" {
  name       = "AmazonMacieServiceRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonMacieServiceRole"
}

resource "aws_iam_policy_attachment" "AmazonMacieServiceRolePolicy" {
  name       = "AmazonMacieServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonMacieServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AmazonMacieSetupRole" {
  name       = "AmazonMacieSetupRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonMacieSetupRole"
}

resource "aws_iam_policy_attachment" "AmazonManagedBlockchainConsoleFullAccess" {
  name       = "AmazonManagedBlockchainConsoleFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonManagedBlockchainConsoleFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonManagedBlockchainFullAccess" {
  name       = "AmazonManagedBlockchainFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonManagedBlockchainFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonManagedBlockchainReadOnlyAccess" {
  name       = "AmazonManagedBlockchainReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonManagedBlockchainReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonMechanicalTurkCrowdFullAccess" {
  name       = "AmazonMechanicalTurkCrowdFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMechanicalTurkCrowdFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonMechanicalTurkCrowdReadOnlyAccess" {
  name       = "AmazonMechanicalTurkCrowdReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMechanicalTurkCrowdReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonMechanicalTurkFullAccess" {
  name       = "AmazonMechanicalTurkFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMechanicalTurkFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonMechanicalTurkReadOnly" {
  name       = "AmazonMechanicalTurkReadOnly"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMechanicalTurkReadOnly"
}

resource "aws_iam_policy_attachment" "AmazonMobileAnalyticsFinancialReportAccess" {
  name       = "AmazonMobileAnalyticsFinancialReportAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMobileAnalyticsFinancialReportAccess"
}

resource "aws_iam_policy_attachment" "AmazonMobileAnalyticsFullAccess" {
  name       = "AmazonMobileAnalyticsFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMobileAnalyticsFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonMobileAnalyticsNon-financialReportAccess" {
  name       = "AmazonMobileAnalyticsNon-financialReportAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMobileAnalyticsNon-financialReportAccess"
}

resource "aws_iam_policy_attachment" "AmazonMobileAnalyticsWriteOnlyAccess" {
  name       = "AmazonMobileAnalyticsWriteOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMobileAnalyticsWriteOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonPersonalizeFullAccess" {
  name       = "AmazonPersonalizeFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonPersonalizeFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonPollyFullAccess" {
  name       = "AmazonPollyFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonPollyFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonPollyReadOnlyAccess" {
  name       = "AmazonPollyReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonPollyReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonRDSBetaServiceRolePolicy" {
  name       = "AmazonRDSBetaServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonRDSBetaServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AmazonRDSDataFullAccess" {
  name       = "AmazonRDSDataFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonRDSDirectoryServiceAccess" {
  name       = "AmazonRDSDirectoryServiceAccess"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSDirectoryServiceAccess"
}

resource "aws_iam_policy_attachment" "AmazonRDSEnhancedMonitoringRole" {
  name       = "AmazonRDSEnhancedMonitoringRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_iam_policy_attachment" "AmazonRDSFullAccess" {
  name       = "AmazonRDSFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonRDSPreviewServiceRolePolicy" {
  name       = "AmazonRDSPreviewServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonRDSPreviewServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AmazonRDSReadOnlyAccess" {
  name       = "AmazonRDSReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonRDSServiceRolePolicy" {
  name       = "AmazonRDSServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonRDSServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AmazonRedshiftFullAccess" {
  name       = "AmazonRedshiftFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonRedshiftQueryEditor" {
  name       = "AmazonRedshiftQueryEditor"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftQueryEditor"
}

resource "aws_iam_policy_attachment" "AmazonRedshiftReadOnlyAccess" {
  name       = "AmazonRedshiftReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonRedshiftServiceLinkedRolePolicy" {
  name       = "AmazonRedshiftServiceLinkedRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonRedshiftServiceLinkedRolePolicy"
}

resource "aws_iam_policy_attachment" "AmazonRekognitionFullAccess" {
  name       = "AmazonRekognitionFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRekognitionFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonRekognitionReadOnlyAccess" {
  name       = "AmazonRekognitionReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRekognitionReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonRekognitionServiceRole" {
  name       = "AmazonRekognitionServiceRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRekognitionServiceRole"
}

resource "aws_iam_policy_attachment" "AmazonRoute53AutoNamingFullAccess" {
  name       = "AmazonRoute53AutoNamingFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53AutoNamingFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonRoute53AutoNamingReadOnlyAccess" {
  name       = "AmazonRoute53AutoNamingReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53AutoNamingReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonRoute53AutoNamingRegistrantAccess" {
  name       = "AmazonRoute53AutoNamingRegistrantAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53AutoNamingRegistrantAccess"
}

resource "aws_iam_policy_attachment" "AmazonRoute53DomainsFullAccess" {
  name       = "AmazonRoute53DomainsFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53DomainsFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonRoute53DomainsReadOnlyAccess" {
  name       = "AmazonRoute53DomainsReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53DomainsReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonRoute53FullAccess" {
  name       = "AmazonRoute53FullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_policy_attachment" "AmazonRoute53ReadOnlyAccess" {
  name       = "AmazonRoute53ReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53ReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonS3FullAccess" {
  name       = "AmazonS3FullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy_attachment" "AmazonS3ReadOnlyAccess" {
  name       = "AmazonS3ReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonSESFullAccess" {
  name       = "AmazonSESFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonSESReadOnlyAccess" {
  name       = "AmazonSESReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonSNSFullAccess" {
  name       = "AmazonSNSFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonSNSReadOnlyAccess" {
  name       = "AmazonSNSReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonSNSRole" {
  name       = "AmazonSNSRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSNSRole"
}

resource "aws_iam_policy_attachment" "AmazonSQSFullAccess" {
  name       = "AmazonSQSFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonSQSReadOnlyAccess" {
  name       = "AmazonSQSReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonSSMAutomationApproverAccess" {
  name       = "AmazonSSMAutomationApproverAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMAutomationApproverAccess"
}

resource "aws_iam_policy_attachment" "AmazonSSMAutomationRole" {
  name       = "AmazonSSMAutomationRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"
}

resource "aws_iam_policy_attachment" "AmazonSSMDirectoryServiceAccess" {
  name       = "AmazonSSMDirectoryServiceAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess"
}

resource "aws_iam_policy_attachment" "AmazonSSMFullAccess" {
  name       = "AmazonSSMFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonSSMMaintenanceWindowRole" {
  name       = "AmazonSSMMaintenanceWindowRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
}

resource "aws_iam_policy_attachment" "AmazonSSMManagedInstanceCore" {
  name       = "AmazonSSMManagedInstanceCore"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "AmazonSSMReadOnlyAccess" {
  name       = "AmazonSSMReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonSSMServiceRolePolicy" {
  name       = "AmazonSSMServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonSSMServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AmazonSageMakerFullAccess" {
  name       = "AmazonSageMakerFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonSageMakerReadOnly" {
  name       = "AmazonSageMakerReadOnly"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerReadOnly"
}

resource "aws_iam_policy_attachment" "AmazonSumerianFullAccess" {
  name       = "AmazonSumerianFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSumerianFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonTextractFullAccess" {
  name       = "AmazonTextractFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonTextractFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonTextractServiceRole" {
  name       = "AmazonTextractServiceRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonTextractServiceRole"
}

resource "aws_iam_policy_attachment" "AmazonTranscribeFullAccess" {
  name       = "AmazonTranscribeFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonTranscribeFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonTranscribeReadOnlyAccess" {
  name       = "AmazonTranscribeReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonTranscribeReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonVPCCrossAccountNetworkInterfaceOperations" {
  name       = "AmazonVPCCrossAccountNetworkInterfaceOperations"
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCCrossAccountNetworkInterfaceOperations"
}

resource "aws_iam_policy_attachment" "AmazonVPCFullAccess" {
  name       = "AmazonVPCFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonVPCReadOnlyAccess" {
  name       = "AmazonVPCReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonWorkLinkFullAccess" {
  name       = "AmazonWorkLinkFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonWorkLinkFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonWorkLinkReadOnly" {
  name       = "AmazonWorkLinkReadOnly"
  policy_arn = "arn:aws:iam::aws:policy/AmazonWorkLinkReadOnly"
}

resource "aws_iam_policy_attachment" "AmazonWorkLinkServiceRolePolicy" {
  name       = "AmazonWorkLinkServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonWorkLinkServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AmazonWorkMailEventsServiceRolePolicy" {
  name       = "AmazonWorkMailEventsServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonWorkMailEventsServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AmazonWorkMailFullAccess" {
  name       = "AmazonWorkMailFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonWorkMailFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonWorkMailReadOnlyAccess" {
  name       = "AmazonWorkMailReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonWorkMailReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AmazonWorkSpacesAdmin" {
  name       = "AmazonWorkSpacesAdmin"
  policy_arn = "arn:aws:iam::aws:policy/AmazonWorkSpacesAdmin"
}

resource "aws_iam_policy_attachment" "AmazonWorkSpacesApplicationManagerAdminAccess" {
  name       = "AmazonWorkSpacesApplicationManagerAdminAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonWorkSpacesApplicationManagerAdminAccess"
}

resource "aws_iam_policy_attachment" "AmazonZocaloFullAccess" {
  name       = "AmazonZocaloFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonZocaloFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonZocaloReadOnlyAccess" {
  name       = "AmazonZocaloReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonZocaloReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "ApplicationAutoScalingForAmazonAppStreamAccess" {
  name       = "ApplicationAutoScalingForAmazonAppStreamAccess"
  policy_arn = "arn:aws:iam::aws:policy/service-role/ApplicationAutoScalingForAmazonAppStreamAccess"
}

resource "aws_iam_policy_attachment" "ApplicationDiscoveryServiceContinuousExportServiceRolePolicy" {
  name       = "ApplicationDiscoveryServiceContinuousExportServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/ApplicationDiscoveryServiceContinuousExportServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "AutoScalingConsoleFullAccess" {
  name       = "AutoScalingConsoleFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingConsoleFullAccess"
}

resource "aws_iam_policy_attachment" "AutoScalingConsoleReadOnlyAccess" {
  name       = "AutoScalingConsoleReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingConsoleReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AutoScalingFullAccess" {
  name       = "AutoScalingFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}

resource "aws_iam_policy_attachment" "AutoScalingNotificationAccessRole" {
  name       = "AutoScalingNotificationAccessRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AutoScalingNotificationAccessRole"
}

resource "aws_iam_policy_attachment" "AutoScalingReadOnlyAccess" {
  name       = "AutoScalingReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "AutoScalingServiceRolePolicy" {
  name       = "AutoScalingServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AutoScalingServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "Billing" {
  name       = "Billing"
  policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
}

resource "aws_iam_policy_attachment" "ClientVPNServiceRolePolicy" {
  name       = "ClientVPNServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/ClientVPNServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "CloudFrontFullAccess" {
  name       = "CloudFrontFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}

resource "aws_iam_policy_attachment" "CloudFrontReadOnlyAccess" {
  name       = "CloudFrontReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "CloudHSMServiceRolePolicy" {
  name       = "CloudHSMServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/CloudHSMServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "CloudSearchFullAccess" {
  name       = "CloudSearchFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/CloudSearchFullAccess"
}

resource "aws_iam_policy_attachment" "CloudSearchReadOnlyAccess" {
  name       = "CloudSearchReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/CloudSearchReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "CloudTrailServiceRolePolicy" {
  name       = "CloudTrailServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/CloudTrailServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "CloudWatchActionsEC2Access" {
  name       = "CloudWatchActionsEC2Access"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access"
}

resource "aws_iam_policy_attachment" "CloudWatchAgentAdminPolicy" {
  name       = "CloudWatchAgentAdminPolicy"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
}

resource "aws_iam_policy_attachment" "CloudWatchAgentServerPolicy" {
  name       = "CloudWatchAgentServerPolicy"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_policy_attachment" "CloudWatchEventsBuiltInTargetExecutionAccess" {
  name       = "CloudWatchEventsBuiltInTargetExecutionAccess"
  policy_arn = "arn:aws:iam::aws:policy/service-role/CloudWatchEventsBuiltInTargetExecutionAccess"
}

resource "aws_iam_policy_attachment" "CloudWatchEventsFullAccess" {
  name       = "CloudWatchEventsFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess"
}

resource "aws_iam_policy_attachment" "CloudWatchEventsInvocationAccess" {
  name       = "CloudWatchEventsInvocationAccess"
  policy_arn = "arn:aws:iam::aws:policy/service-role/CloudWatchEventsInvocationAccess"
}

resource "aws_iam_policy_attachment" "CloudWatchEventsReadOnlyAccess" {
  name       = "CloudWatchEventsReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchEventsReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "CloudWatchEventsServiceRolePolicy" {
  name       = "CloudWatchEventsServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/CloudWatchEventsServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "CloudWatchFullAccess" {
  name       = "CloudWatchFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_policy_attachment" "CloudWatchLogsFullAccess" {
  name       = "CloudWatchLogsFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_policy_attachment" "CloudWatchLogsReadOnlyAccess" {
  name       = "CloudWatchLogsReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "CloudWatchReadOnlyAccess" {
  name       = "CloudWatchReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "CloudwatchApplicationInsightsServiceLinkedRolePolicy" {
  name       = "CloudwatchApplicationInsightsServiceLinkedRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/CloudwatchApplicationInsightsServiceLinkedRolePolicy"
}

resource "aws_iam_policy_attachment" "ComprehendDataAccessRolePolicy" {
  name       = "ComprehendDataAccessRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/service-role/ComprehendDataAccessRolePolicy"
}

resource "aws_iam_policy_attachment" "ComprehendFullAccess" {
  name       = "ComprehendFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/ComprehendFullAccess"
}

resource "aws_iam_policy_attachment" "ComprehendMedicalFullAccess" {
  name       = "ComprehendMedicalFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/ComprehendMedicalFullAccess"
}

resource "aws_iam_policy_attachment" "ComprehendReadOnly" {
  name       = "ComprehendReadOnly"
  policy_arn = "arn:aws:iam::aws:policy/ComprehendReadOnly"
}

resource "aws_iam_policy_attachment" "DAXServiceRolePolicy" {
  name       = "DAXServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/DAXServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "DataScientist" {
  name       = "DataScientist"
  policy_arn = "arn:aws:iam::aws:policy/job-function/DataScientist"
}

resource "aws_iam_policy_attachment" "DatabaseAdministrator" {
  name       = "DatabaseAdministrator"
  policy_arn = "arn:aws:iam::aws:policy/job-function/DatabaseAdministrator"
}

resource "aws_iam_policy_attachment" "DynamoDBReplicationServiceRolePolicy" {
  name       = "DynamoDBReplicationServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/DynamoDBReplicationServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "ElastiCacheServiceRolePolicy" {
  name       = "ElastiCacheServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/ElastiCacheServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "ElasticLoadBalancingFullAccess" {
  name       = "ElasticLoadBalancingFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
}

resource "aws_iam_policy_attachment" "ElasticLoadBalancingReadOnly" {
  name       = "ElasticLoadBalancingReadOnly"
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingReadOnly"
}

resource "aws_iam_policy_attachment" "FMSServiceRolePolicy" {
  name       = "FMSServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/FMSServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "FSxDeleteServiceLinkedRoleAccess" {
  name       = "FSxDeleteServiceLinkedRoleAccess"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/FSxDeleteServiceLinkedRoleAccess"
}

resource "aws_iam_policy_attachment" "Force_MFA" {
  groups     = ["Admin"]
  name       = "Force_MFA"
  policy_arn = "arn:aws:iam::302617221463:policy/Force_MFA"
}

resource "aws_iam_policy_attachment" "GlobalAcceleratorFullAccess" {
  name       = "GlobalAcceleratorFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/GlobalAcceleratorFullAccess"
}

resource "aws_iam_policy_attachment" "GlobalAcceleratorReadOnlyAccess" {
  name       = "GlobalAcceleratorReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/GlobalAcceleratorReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "GreengrassOTAUpdateArtifactAccess" {
  name       = "GreengrassOTAUpdateArtifactAccess"
  policy_arn = "arn:aws:iam::aws:policy/service-role/GreengrassOTAUpdateArtifactAccess"
}

resource "aws_iam_policy_attachment" "IAMFullAccess" {
  name       = "IAMFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_policy_attachment" "IAMReadOnlyAccess" {
  name       = "IAMReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "IAMSelfManageServiceSpecificCredentials" {
  name       = "IAMSelfManageServiceSpecificCredentials"
  policy_arn = "arn:aws:iam::aws:policy/IAMSelfManageServiceSpecificCredentials"
}

resource "aws_iam_policy_attachment" "IAMUserChangePassword" {
  name       = "IAMUserChangePassword"
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
  users      = ["gmlthak12"]
}

resource "aws_iam_policy_attachment" "IAMUserSSHKeys" {
  name       = "IAMUserSSHKeys"
  policy_arn = "arn:aws:iam::aws:policy/IAMUserSSHKeys"
}

resource "aws_iam_policy_attachment" "KafkaServiceRolePolicy" {
  name       = "KafkaServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/KafkaServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "LexBotPolicy" {
  name       = "LexBotPolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/LexBotPolicy"
}

resource "aws_iam_policy_attachment" "LexChannelPolicy" {
  name       = "LexChannelPolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/LexChannelPolicy"
}

resource "aws_iam_policy_attachment" "LightsailExportAccess" {
  name       = "LightsailExportAccess"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/LightsailExportAccess"
}

resource "aws_iam_policy_attachment" "NeptuneConsoleFullAccess" {
  name       = "NeptuneConsoleFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/NeptuneConsoleFullAccess"
}

resource "aws_iam_policy_attachment" "NeptuneFullAccess" {
  name       = "NeptuneFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/NeptuneFullAccess"
}

resource "aws_iam_policy_attachment" "NeptuneReadOnlyAccess" {
  name       = "NeptuneReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/NeptuneReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "NetworkAdministrator" {
  name       = "NetworkAdministrator"
  policy_arn = "arn:aws:iam::aws:policy/job-function/NetworkAdministrator"
}

resource "aws_iam_policy_attachment" "Packer" {
  name       = "Packer"
  policy_arn = "arn:aws:iam::302617221463:policy/Packer"
  users      = ["packer"]
}

resource "aws_iam_policy_attachment" "PowerUserAccess" {
  name       = "PowerUserAccess"
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_policy_attachment" "QuickSightAccessForS3StorageManagementAnalyticsReadOnly" {
  name       = "QuickSightAccessForS3StorageManagementAnalyticsReadOnly"
  policy_arn = "arn:aws:iam::aws:policy/service-role/QuickSightAccessForS3StorageManagementAnalyticsReadOnly"
}

resource "aws_iam_policy_attachment" "RDSCloudHsmAuthorizationRole" {
  name       = "RDSCloudHsmAuthorizationRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/RDSCloudHsmAuthorizationRole"
}

resource "aws_iam_policy_attachment" "ReadOnlyAccess" {
  name       = "ReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "ResourceGroupsandTagEditorFullAccess" {
  name       = "ResourceGroupsandTagEditorFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/ResourceGroupsandTagEditorFullAccess"
}

resource "aws_iam_policy_attachment" "ResourceGroupsandTagEditorReadOnlyAccess" {
  name       = "ResourceGroupsandTagEditorReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/ResourceGroupsandTagEditorReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "SecretsManagerReadWrite" {
  name       = "SecretsManagerReadWrite"
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_policy_attachment" "SecurityAudit" {
  name       = "SecurityAudit"
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_policy_attachment" "ServerMigrationConnector" {
  name       = "ServerMigrationConnector"
  policy_arn = "arn:aws:iam::aws:policy/ServerMigrationConnector"
}

resource "aws_iam_policy_attachment" "ServerMigrationServiceLaunchRole" {
  name       = "ServerMigrationServiceLaunchRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/ServerMigrationServiceLaunchRole"
}

resource "aws_iam_policy_attachment" "ServerMigrationServiceRole" {
  name       = "ServerMigrationServiceRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/ServerMigrationServiceRole"
}

resource "aws_iam_policy_attachment" "ServiceCatalogAdminReadOnlyAccess" {
  name       = "ServiceCatalogAdminReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/ServiceCatalogAdminReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "ServiceCatalogEndUserAccess" {
  name       = "ServiceCatalogEndUserAccess"
  policy_arn = "arn:aws:iam::aws:policy/ServiceCatalogEndUserAccess"
}

resource "aws_iam_policy_attachment" "SimpleWorkflowFullAccess" {
  name       = "SimpleWorkflowFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/SimpleWorkflowFullAccess"
}

resource "aws_iam_policy_attachment" "SupportUser" {
  name       = "SupportUser"
  policy_arn = "arn:aws:iam::aws:policy/job-function/SupportUser"
}

resource "aws_iam_policy_attachment" "SystemAdministrator" {
  name       = "SystemAdministrator"
  policy_arn = "arn:aws:iam::aws:policy/job-function/SystemAdministrator"
}

resource "aws_iam_policy_attachment" "TagPoliciesServiceRolePolicy" {
  name       = "TagPoliciesServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/TagPoliciesServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "TranslateFullAccess" {
  name       = "TranslateFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/TranslateFullAccess"
}

resource "aws_iam_policy_attachment" "TranslateReadOnly" {
  name       = "TranslateReadOnly"
  policy_arn = "arn:aws:iam::aws:policy/TranslateReadOnly"
}

resource "aws_iam_policy_attachment" "VMImportExportRoleForAWSConnector" {
  name       = "VMImportExportRoleForAWSConnector"
  policy_arn = "arn:aws:iam::aws:policy/service-role/VMImportExportRoleForAWSConnector"
}

resource "aws_iam_policy_attachment" "ViewOnlyAccess" {
  name       = "ViewOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}

resource "aws_iam_policy_attachment" "WAFLoggingServiceRolePolicy" {
  name       = "WAFLoggingServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/WAFLoggingServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "WAFRegionalLoggingServiceRolePolicy" {
  name       = "WAFRegionalLoggingServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/WAFRegionalLoggingServiceRolePolicy"
}

resource "aws_iam_policy_attachment" "WellArchitectedConsoleFullAccess" {
  name       = "WellArchitectedConsoleFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/WellArchitectedConsoleFullAccess"
}

resource "aws_iam_policy_attachment" "WellArchitectedConsoleReadOnlyAccess" {
  name       = "WellArchitectedConsoleReadOnlyAccess"
  policy_arn = "arn:aws:iam::aws:policy/WellArchitectedConsoleReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "WorkLinkServiceRolePolicy" {
  name       = "WorkLinkServiceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/WorkLinkServiceRolePolicy"
}
