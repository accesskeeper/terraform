



resource "aws_cloudformation_stack" "waf_security_automations_alb" {
  name = "${var.name}"
  capabilities = ["CAPABILITY_IAM"]
  parameters {
    AccessLogBucket = "${var.accesslogbucket}"
    SqlInjectionProtectionParam = "${var.sqlinjection}"
    CrossSiteScriptingProtectionParam = "${var.xss}"
    ActivateHttpFloodProtectionParam = "${var.httpflood}"
    ActivateScansProbesProtectionParam = "${var.scansprobe}"
    ActivateReputationListsProtectionParam = "${var.reputationlists}"
    ActivateBadBotProtectionParam = "${var.badbot}"
    RequestThreshold = "${var.httprequeststhreshold}"
    ErrorThreshold = "${var.scansprobeserrorthreshold}"
    WAFBlockPeriod = "${var.wafblockperiod}"
    AlbID = "${var.albid}"
  }

  on_failure = "ROLLBACK"

  tags {
    project = "${var.project}"
    squad = "${var.squad}"
  }
  #template_url = "${file("${path.module}/aws-waf-security-automations-alb-no_desc.tpl")}" - max 1024 lines!
  template_body = <<STACK
  {
  "AWSTemplateFormatVersion": "2010-09-09",
  "Description": "",
  "Metadata": {
    "AWS::CloudFormation::Interface": {
      "ParameterGroups": [{
        "Label": {
          "default": "Protection List"
        },
        "Parameters": ["SqlInjectionProtectionParam", "CrossSiteScriptingProtectionParam", "ActivateHttpFloodProtectionParam", "ActivateScansProbesProtectionParam", "ActivateReputationListsProtectionParam", "ActivateBadBotProtectionParam"]
      }, {
        "Label": {
          "default": "Settings"
        },
        "Parameters": ["AccessLogBucket"]
      }, {
        "Label": {
          "default": "Advanced Settings"
        },
        "Parameters": ["RequestThreshold", "ErrorThreshold", "WAFBlockPeriod"]
      }, {
        "Label": {
          "default": "Anonymous Metrics Request"
        },
        "Parameters": ["SendAnonymousUsageData"]
      }],
      "ParameterLabels": {
        "SqlInjectionProtectionParam": {
          "default": "Activate SQL Injection Protection"
        },
        "CrossSiteScriptingProtectionParam": {
          "default": "Activate Cross-site Scripting Protection"
        },
        "ActivateHttpFloodProtectionParam": {
          "default": "Activate HTTP Flood Protection"
        },
        "ActivateScansProbesProtectionParam": {
          "default": "Activate Scanner & Probe Protection"
        },
        "ActivateReputationListsProtectionParam": {
          "default": "Activate Reputation List Protection"
        },
        "ActivateBadBotProtectionParam": {
          "default": "Activate Bad Bot Protection"
        },
        "AccessLogBucket": {
          "default": "ALB Access Log Bucket Name"
        },
        "SendAnonymousUsageData": {
          "default": "Send Anonymous Usage Data"
        },
        "RequestThreshold": {
          "default": "Request Threshold"
        },
        "ErrorThreshold": {
          "default": "Error Threshold"
        },
        "WAFBlockPeriod": {
          "default": "WAF Block Period"
        },
        "AlbID": {
          "default": "ALB ID to associate the WAF with"
        }
      }
    }
  },


  "Parameters": {
    "SqlInjectionProtectionParam": {
      "Type": "String",
      "Default": "yes",
      "AllowedValues": ["yes", "no"]
    },
    "CrossSiteScriptingProtectionParam": {
      "Type": "String",
      "Default": "yes",
      "AllowedValues": ["yes", "no"]
    },
    "ActivateHttpFloodProtectionParam": {
      "Type": "String",
      "Default": "yes",
      "AllowedValues": ["yes", "no"]
    },
    "ActivateScansProbesProtectionParam": {
      "Type": "String",
      "Default": "yes",
      "AllowedValues": ["yes", "no"]
    },
    "ActivateReputationListsProtectionParam": {
      "Type": "String",
      "Default": "yes",
      "AllowedValues": ["yes", "no"]
    },
    "ActivateBadBotProtectionParam": {
      "Type": "String",
      "Default": "yes",
      "AllowedValues": ["yes", "no"]
    },
    "AccessLogBucket": {
      "Type": "String",
      "Default": "",
      "AllowedPattern": "(^$|^([a-z]|(\\d(?!\\d{0,2}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3})))([a-z\\d]|(\\.(?!(\\.|-)))|(-(?!\\.))){1,61}[a-z\\d]$)"
    },
    "SendAnonymousUsageData": {
      "Type": "String",
      "Default": "yes",
      "AllowedValues": ["yes", "no"]
    },
    "RequestThreshold": {
      "Type": "Number",
      "Default": "2000",
      "MinValue": "2000"
    },
    "ErrorThreshold": {
      "Type": "Number",
      "Default": "50",
      "MinValue": "0"
    },
    "WAFBlockPeriod": {
      "Type": "Number",
      "Default": "240",
      "MinValue": "0"
    },
    "AlbID": {
      "Type": "String",
      "Default": ""
    }
  },


  "Conditions": {
    "SqlInjectionProtectionActivated": {
      "Fn::Equals": [{
        "Ref": "SqlInjectionProtectionParam"
      }, "yes"]
    },
    "CrossSiteScriptingProtectionActivated": {
      "Fn::Equals": [{
        "Ref": "CrossSiteScriptingProtectionParam"
      }, "yes"]
    },
    "HttpFloodProtectionActivated": {
      "Fn::Equals": [{
        "Ref": "ActivateHttpFloodProtectionParam"
      }, "yes"]
    },
    "ScansProbesProtectionActivated": {
      "Fn::Equals": [{
        "Ref": "ActivateScansProbesProtectionParam"
      }, "yes"]
    },
    "ReputationListsProtectionActivated": {
      "Fn::Equals": [{
        "Ref": "ActivateReputationListsProtectionParam"
      }, "yes"]
    },
    "BadBotProtectionActivated": {
      "Fn::Equals": [{
        "Ref": "ActivateBadBotProtectionParam"
      }, "yes"]
    },
    "LogParserActivated": {
      "Fn::Equals": [{
        "Ref": "ActivateScansProbesProtectionParam"
      }, "yes"]
    },
    "CreateWebACL": {
      "Fn::Or": [{
        "Condition": "SqlInjectionProtectionActivated"
      }, {
        "Condition": "CrossSiteScriptingProtectionActivated"
      }, {
        "Condition": "HttpFloodProtectionActivated"
      }, {
        "Condition": "ScansProbesProtectionActivated"
      }, {
        "Condition": "ReputationListsProtectionActivated"
      }, {
        "Condition": "BadBotProtectionActivated"
      }]
    }
  },
  "Resources": {
    "WAFWhitelistSet": {
      "Type": "AWS::WAFRegional::IPSet",
      "Condition": "CreateWebACL",
      "Properties": {
        "Name": {
          "Fn::Join": [" - ", [{
            "Ref": "AWS::StackName"
          }, "Whitelist Set"]]
        }
      }
    },
    "WAFBlacklistSet": {
      "Type": "AWS::WAFRegional::IPSet",
      "Condition": "LogParserActivated",
      "Properties": {
        "Name": {
          "Fn::Join": [" - ", [{
            "Ref": "AWS::StackName"
          }, "Blacklist Set"]]
        }
      }
    },
    "WAFScansProbesSet": {
      "Type": "AWS::WAFRegional::IPSet",
      "Condition": "LogParserActivated",
      "Properties": {
        "Name": {
          "Fn::Join": [" - ", [{
            "Ref": "AWS::StackName"
          }, "Scans Probes Set"]]
        }
      }
    },
    "WAFReputationListsSet1": {
      "Type": "AWS::WAFRegional::IPSet",
      "Condition": "ReputationListsProtectionActivated",
      "Properties": {
        "Name": {
          "Fn::Join": [" - ", [{
            "Ref": "AWS::StackName"
          }, "IP Reputation Lists Set #1"]]
        }
      }
    },
    "WAFReputationListsSet2": {
      "Type": "AWS::WAFRegional::IPSet",
      "Condition": "ReputationListsProtectionActivated",
      "Properties": {
        "Name": {
          "Fn::Join": [" - ", [{
            "Ref": "AWS::StackName"
          }, "IP Reputation Lists Set #2"]]
        }
      }
    },
    "WAFBadBotSet": {
      "Type": "AWS::WAFRegional::IPSet",
      "Condition": "BadBotProtectionActivated",
      "Properties": {
        "Name": {
          "Fn::Join": [" - ", [{
            "Ref": "AWS::StackName"
          }, "IP Bad Bot Set"]]
        }
      }
    },
    "WAFSqlInjectionDetection": {
      "Type": "AWS::WAFRegional::SqlInjectionMatchSet",
      "Condition": "SqlInjectionProtectionActivated",
      "Properties": {
        "Name": {
          "Fn::Join": [" - ", [{
            "Ref": "AWS::StackName"
          }, "SQL injection Detection"]]
        },
        "SqlInjectionMatchTuples": [{
          "FieldToMatch": {
            "Type": "QUERY_STRING"
          },
          "TextTransformation": "URL_DECODE"
        }, {
          "FieldToMatch": {
            "Type": "QUERY_STRING"
          },
          "TextTransformation": "HTML_ENTITY_DECODE"
        }, {
          "FieldToMatch": {
            "Type": "BODY"
          },
          "TextTransformation": "URL_DECODE"
        }, {
          "FieldToMatch": {
            "Type": "BODY"
          },
          "TextTransformation": "HTML_ENTITY_DECODE"
        }, {
          "FieldToMatch": {
            "Type": "URI"
          },
          "TextTransformation": "URL_DECODE"
        }, {
          "FieldToMatch": {
            "Type": "URI"
          },
          "TextTransformation": "HTML_ENTITY_DECODE"
        }, {
          "FieldToMatch": {
            "Type": "HEADER",
            "Data": "Cookie"
          },
          "TextTransformation": "URL_DECODE"
        }, {
          "FieldToMatch": {
            "Type": "HEADER",
            "Data": "Cookie"
          },
          "TextTransformation": "HTML_ENTITY_DECODE"
        }, {
          "FieldToMatch": {
            "Type": "HEADER",
            "Data": "Authorization"
          },
          "TextTransformation": "URL_DECODE"
        }, {
          "FieldToMatch": {
            "Type": "HEADER",
            "Data": "Authorization"
          },
          "TextTransformation": "HTML_ENTITY_DECODE"
        }]
      }
    },
    "WAFXssDetection": {
      "Type": "AWS::WAFRegional::XssMatchSet",
      "Condition": "CrossSiteScriptingProtectionActivated",
      "Properties": {
        "Name": {
          "Fn::Join": [" - ", [{
            "Ref": "AWS::StackName"
          }, "XSS Detection Detection"]]
        },
        "XssMatchTuples": [{
          "FieldToMatch": {
            "Type": "QUERY_STRING"
          },
          "TextTransformation": "URL_DECODE"
        }, {
          "FieldToMatch": {
            "Type": "QUERY_STRING"
          },
          "TextTransformation": "HTML_ENTITY_DECODE"
        }, {
          "FieldToMatch": {
            "Type": "BODY"
          },
          "TextTransformation": "URL_DECODE"
        }, {
          "FieldToMatch": {
            "Type": "BODY"
          },
          "TextTransformation": "HTML_ENTITY_DECODE"
        }, {
          "FieldToMatch": {
            "Type": "URI"
          },
          "TextTransformation": "URL_DECODE"
        }, {
          "FieldToMatch": {
            "Type": "URI"
          },
          "TextTransformation": "HTML_ENTITY_DECODE"
        }, {
          "FieldToMatch": {
            "Type": "HEADER",
            "Data": "Cookie"
          },
          "TextTransformation": "URL_DECODE"
        }, {
          "FieldToMatch": {
            "Type": "HEADER",
            "Data": "Cookie"
          },
          "TextTransformation": "HTML_ENTITY_DECODE"
        }]
      }
    },
    "WAFWhitelistRule": {
      "Type": "AWS::WAFRegional::Rule",
      "Condition": "CreateWebACL",
      "DependsOn": "WAFWhitelistSet",
      "Properties": {
        "Name": {
          "Fn::Join": [" - ", [{
            "Ref": "AWS::StackName"
          }, "Whitelist Rule"]]
        },
        "MetricName": "SecurityAutomationsWhitelistRule",
        "Predicates": [{
          "DataId": {
            "Ref": "WAFWhitelistSet"
          },
          "Negated": false,
          "Type": "IPMatch"
        }]
      }
    },
    "WAFBlacklistRule": {
      "Type": "AWS::WAFRegional::Rule",
      "Condition": "LogParserActivated",
      "DependsOn": "WAFBlacklistSet",
      "Properties": {
        "Name": {
          "Fn::Join": [" - ", [{
            "Ref": "AWS::StackName"
          }, "Blacklist Rule"]]
        },
        "MetricName": "SecurityAutomationsBlacklistRule",
        "Predicates": [{
          "DataId": {
            "Ref": "WAFBlacklistSet"
          },
          "Negated": false,
          "Type": "IPMatch"
        }]
      }
    },
    "WAFScansProbesRule": {
      "Type": "AWS::WAFRegional::Rule",
      "Condition": "LogParserActivated",
      "DependsOn": "WAFScansProbesSet",
      "Properties": {
        "Name": {
          "Fn::Join": [" - ", [{
            "Ref": "AWS::StackName"
          }, "Scans Probes Rule"]]
        },
        "MetricName": "SecurityAutomationsScansProbesRule",
        "Predicates": [{
          "DataId": {
            "Ref": "WAFScansProbesSet"
          },
          "Negated": false,
          "Type": "IPMatch"
        }]
      }
    },
    "WAFIPReputationListsRule1": {
      "Type": "AWS::WAFRegional::Rule",
      "Condition": "ReputationListsProtectionActivated",
      "DependsOn": "WAFReputationListsSet1",
      "Properties": {
        "Name": {
          "Fn::Join": [" - ", [{
            "Ref": "AWS::StackName"
          }, "WAF IP Reputation Lists Rule #1"]]
        },
        "MetricName": "SecurityAutomationsIPReputationListsRule1",
        "Predicates": [{
          "DataId": {
            "Ref": "WAFReputationListsSet1"
          },
          "Type": "IPMatch",
          "Negated": "false"
        }]
      }
    },
    "WAFIPReputationListsRule2": {
      "Type": "AWS::WAFRegional::Rule",
      "Condition": "ReputationListsProtectionActivated",
      "DependsOn": "WAFReputationListsSet2",
      "Properties": {
        "Name": {
          "Fn::Join": [" - ", [{
            "Ref": "AWS::StackName"
          }, "WAF IP Reputation Lists Rule #2"]]
        },
        "MetricName": "SecurityAutomationsIPReputationListsRule2",
        "Predicates": [{
          "DataId": {
            "Ref": "WAFReputationListsSet2"
          },
          "Type": "IPMatch",
          "Negated": "false"
        }]
      }
    },
    "WAFBadBotRule": {
      "Type": "AWS::WAFRegional::Rule",
      "Condition": "BadBotProtectionActivated",
      "DependsOn": "WAFBadBotSet",
      "Properties": {
        "Name": {
          "Fn::Join": [" - ", [{
            "Ref": "AWS::StackName"
          }, "Bad Bot Rule"]]
        },
        "MetricName": "SecurityAutomationsBadBotRule",
        "Predicates": [{
          "DataId": {
            "Ref": "WAFBadBotSet"
          },
          "Type": "IPMatch",
          "Negated": "false"
        }]
      }
    },
    "WAFSqlInjectionRule": {
      "Type": "AWS::WAFRegional::Rule",
      "Condition": "SqlInjectionProtectionActivated",
      "DependsOn": "WAFSqlInjectionDetection",
      "Properties": {
        "Name": {
          "Fn::Join": [" - ", [{
            "Ref": "AWS::StackName"
          }, "SQL Injection Rule"]]
        },
        "MetricName": "SecurityAutomationsSqlInjectionRule",
        "Predicates": [{
          "DataId": {
            "Ref": "WAFSqlInjectionDetection"
          },
          "Negated": false,
          "Type": "SqlInjectionMatch"
        }]
      }
    },
    "WAFXssRule": {
      "Type": "AWS::WAFRegional::Rule",
      "Condition": "CrossSiteScriptingProtectionActivated",
      "DependsOn": "WAFXssDetection",
      "Properties": {
        "Name": {
          "Fn::Join": [" - ", [{
            "Ref": "AWS::StackName"
          }, "XSS Rule"]]
        },
        "MetricName": "SecurityAutomationsXssRule",
        "Predicates": [{
          "DataId": {
            "Ref": "WAFXssDetection"
          },
          "Negated": false,
          "Type": "XssMatch"
        }]
      }
    },
    "WAFWebACL": {
      "Type": "AWS::WAFRegional::WebACL",
      "Condition": "CreateWebACL",
      "DependsOn": ["WAFWhitelistRule"],
      "Properties": {
        "Name": {
          "Ref": "AWS::StackName"
        },
        "DefaultAction": {
          "Type": "ALLOW"
        },
        "MetricName": "SecurityAutomationsMaliciousRequesters",
        "Rules": [{
          "Action": {
            "Type": "ALLOW"
          },
          "Priority": 10,
          "RuleId": {
            "Ref": "WAFWhitelistRule"
          }
        }]
      }
    },
    "WAFWebACLAssociation": {
      "Type": "AWS::WAFRegional::WebACLAssociation",
      "Properties": {
        "ResourceArn": { "Ref": "AlbID" },
        "WebACLId": { "Ref": "WAFWebACL" }
      }
    },
    "LambdaRoleLogParser": {
      "Type": "AWS::IAM::Role",
      "Condition": "LogParserActivated",
      "Properties": {
        "AssumeRolePolicyDocument": {
          "Version": "2012-10-17",
          "Statement": [{
            "Effect": "Allow",
            "Principal": {
              "Service": ["lambda.amazonaws.com"]
            },
            "Action": ["sts:AssumeRole"]
          }]
        },
        "Path": "/",
        "Policies": [{
          "PolicyName": "S3Access",
          "PolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [{
              "Effect": "Allow",
              "Action": "s3:GetObject",
              "Resource": {
                "Fn::Join": ["", ["arn:aws:s3:::", {
                  "Ref": "AccessLogBucket"
                }, "/*"]]
              }
            }]
          }
        }, {
          "PolicyName": "S3AccessPut",
          "PolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [{
              "Effect": "Allow",
              "Action": "s3:PutObject",
              "Resource": {
                "Fn::Join": ["", ["arn:aws:s3:::", {
                  "Ref": "AccessLogBucket"
                }, "/aws-waf-security-automations-current-blocked-ips.json"]]
              }
            }]
          }
        }, {
          "PolicyName": "WAFGetChangeToken",
          "PolicyDocument": {
            "Statement": [{
              "Effect": "Allow",
              "Action": "waf-regional:GetChangeToken",
              "Resource": "*"
            }]
          }
        }, {
          "PolicyName": "WAFGetAndUpdateIPSet",
          "PolicyDocument": {
            "Statement": [{
              "Effect": "Allow",
              "Action": [
                "waf-regional:GetIPSet",
                "waf-regional:UpdateIPSet"
              ],
              "Resource": [{
                "Fn::Join": [
                  "", [
                    "arn:aws:waf-regional:", {
                      "Ref": "AWS::Region"
                    }, ":", {
                      "Ref": "AWS::AccountId"
                    },
                    ":ipset/", {
                      "Ref": "WAFBlacklistSet"
                    }
                  ]
                ]
              }, {
                "Fn::Join": [
                  "", [
                    "arn:aws:waf-regional:", {
                      "Ref": "AWS::Region"
                    }, ":", {
                      "Ref": "AWS::AccountId"
                    },
                    ":ipset/", {
                      "Ref": "WAFScansProbesSet"
                    }
                  ]
                ]
              }]
            }]
          }
        }, {
          "PolicyName": "LogsAccess",
          "PolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [{
              "Effect": "Allow",
              "Action": ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
              "Resource": {
                "Fn::Join": [":", ["arn:aws:logs", {
                  "Ref": "AWS::Region"
                }, {
                  "Ref": "AWS::AccountId"
                }, "log-group:/aws/lambda/*"]]
              }
            }]
          }
        }, {
          "PolicyName": "CloudWatchAccess",
          "PolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [{
              "Effect": "Allow",
              "Action": "cloudwatch:GetMetricStatistics",
              "Resource": "*"
            }]
          }
        }]
      }
    },
    "LambdaWAFLogParserFunction": {
      "Type": "AWS::Lambda::Function",
      "Condition": "LogParserActivated",
      "DependsOn": ["LambdaRoleLogParser", "WAFBlacklistSet", "WAFScansProbesSet"],
      "Properties": {
        "Description": {
          "Fn::Join": ["", [
            "This function parses ALB access logs to identify suspicious behavior, such as an abnormal amount of errors. It then blocks those IP addresses for a customer-defined period of time. Parameters: ", {
              "Ref": "ErrorThreshold"
            },
            ",", {
              "Ref": "WAFBlockPeriod"
            },
            "."
          ]]
        },
        "Handler": "log-parser.lambda_handler",
        "Role": {
          "Fn::GetAtt": ["LambdaRoleLogParser", "Arn"]
        },
        "Code": {
          "S3Bucket": {
            "Fn::Join": ["-", [
              "solutions", {
                "Ref": "AWS::Region"
              }
            ]]
          },
          "S3Key": "aws-waf-security-automations/v2/log-parser.zip"
        },
        "Environment": {
          "Variables": {
            "OUTPUT_BUCKET": {
              "Ref": "AccessLogBucket"
            },
            "IP_SET_ID_BLACKLIST": {
              "Ref": "WAFBlacklistSet"
            },
            "IP_SET_ID_AUTO_BLOCK": {
              "Ref": "WAFScansProbesSet"
            },
            "BLACKLIST_BLOCK_PERIOD": {
              "Ref": "WAFBlockPeriod"
            },
            "ERROR_PER_MINUTE_LIMIT": {
              "Ref": "ErrorThreshold"
            },
            "SEND_ANONYMOUS_USAGE_DATA": {
              "Ref": "SendAnonymousUsageData"
            },
            "UUID": {
              "Fn::GetAtt": ["CreateUniqueID", "UUID"]
            },
            "LIMIT_IP_ADDRESS_RANGES_PER_IP_MATCH_CONDITION": "10000",
            "MAX_AGE_TO_UPDATE": "30",
            "REGION": {
              "Ref": "AWS::Region"
            },
            "LOG_TYPE": "alb"
          }
        },
        "Runtime": "python2.7",
        "MemorySize": "512",
        "Timeout": "300"
      }
    },
    "LambdaInvokePermissionLogParser": {
      "Type": "AWS::Lambda::Permission",
      "Condition": "LogParserActivated",
      "DependsOn": "LambdaWAFLogParserFunction",
      "Properties": {
        "FunctionName": {
          "Fn::GetAtt": ["LambdaWAFLogParserFunction", "Arn"]
        },
        "Action": "lambda:*",
        "Principal": "s3.amazonaws.com",
        "SourceAccount": {
          "Ref": "AWS::AccountId"
        }
      }
    },
    "LambdaRoleReputationListsParser": {
      "Type": "AWS::IAM::Role",
      "Condition": "ReputationListsProtectionActivated",
      "Properties": {
        "AssumeRolePolicyDocument": {
          "Statement": [{
            "Effect": "Allow",
            "Principal": {
              "Service": [
                "lambda.amazonaws.com"
              ]
            },
            "Action": "sts:AssumeRole"
          }]
        },
        "Policies": [{
          "PolicyName": "CloudWatchLogs",
          "PolicyDocument": {
            "Statement": [{
              "Effect": "Allow",
              "Action": ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
              "Resource": {
                "Fn::Join": [":", ["arn:aws:logs", {
                  "Ref": "AWS::Region"
                }, {
                  "Ref": "AWS::AccountId"
                }, "log-group:/aws/lambda/*"]]
              }
            }]
          }
        }, {
          "PolicyName": "WAFGetChangeToken",
          "PolicyDocument": {
            "Statement": [{
              "Effect": "Allow",
              "Action": "waf-regional:GetChangeToken",
              "Resource": "*"
            }]
          }
        }, {
          "PolicyName": "WAFGetAndUpdateIPSet",
          "PolicyDocument": {
            "Statement": [{
              "Effect": "Allow",
              "Action": [
                "waf-regional:GetIPSet",
                "waf-regional:UpdateIPSet"
              ],
              "Resource": [{
                "Fn::Join": [
                  "", [
                    "arn:aws:waf-regional:", {
                      "Ref": "AWS::Region"
                    }, ":", {
                      "Ref": "AWS::AccountId"
                    },
                    ":ipset/", {
                      "Ref": "WAFReputationListsSet1"
                    }
                  ]
                ]
              }, {
                "Fn::Join": [
                  "", [
                    "arn:aws:waf-regional:", {
                      "Ref": "AWS::Region"
                    }, ":", {
                      "Ref": "AWS::AccountId"
                    },
                    ":ipset/", {
                      "Ref": "WAFReputationListsSet2"
                    }
                  ]
                ]
              }]
            }]
          }
        }, {
          "PolicyName": "CloudFormationAccess",
          "PolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [{
              "Effect": "Allow",
              "Action": "cloudformation:DescribeStacks",
              "Resource": {
                "Fn::Join": [
                  "", [
                    "arn:aws:cloudformation:", {
                      "Ref": "AWS::Region"
                    },
                    ":", {
                      "Ref": "AWS::AccountId"
                    },
                    ":stack/", {
                      "Ref": "AWS::StackName"
                    },
                    "/*"
                  ]
                ]
              }
            }]
          }
        }, {
          "PolicyName": "CloudWatchAccess",
          "PolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [{
              "Effect": "Allow",
              "Action": "cloudwatch:GetMetricStatistics",
              "Resource": "*"
            }]
          }
        }]
      }
    },
    "LambdaWAFReputationListsParserFunction": {
      "Type": "AWS::Lambda::Function",
      "Condition": "ReputationListsProtectionActivated",
      "DependsOn": "LambdaRoleReputationListsParser",
      "Properties": {
        "Description": "This lambda function checks third-party IP reputation lists hourly for new IP ranges to block. These lists include the Spamhaus Dont Route Or Peer (DROP) and Extended Drop (EDROP) lists, the Proofpoint Emerging Threats IP list, and the Tor exit node list.",
        "Handler": "reputation-lists-parser.handler",
        "Role": {
          "Fn::GetAtt": [
            "LambdaRoleReputationListsParser",
            "Arn"
          ]
        },
        "Code": {
          "S3Bucket": {
            "Fn::Join": ["-", [
              "solutions", {
                "Ref": "AWS::Region"
              }
            ]]
          },
          "S3Key": "aws-waf-security-automations/v3/reputation-lists-parser.zip"
        },
        "Runtime": "nodejs6.10",
        "MemorySize": "128",
        "Timeout": "300",
        "Environment": {
          "Variables": {
            "SEND_ANONYMOUS_USAGE_DATA": {
              "Ref": "SendAnonymousUsageData"
            },
            "UUID": {
              "Fn::GetAtt": ["CreateUniqueID", "UUID"]
            }
          }
        }
      }
    },
    "LambdaWAFReputationListsParserEventsRule": {
      "Type": "AWS::Events::Rule",
      "Condition": "ReputationListsProtectionActivated",
      "DependsOn": ["LambdaWAFReputationListsParserFunction", "WAFReputationListsSet1", "WAFReputationListsSet2"],
      "Properties": {
        "Description": "Security Automations - WAF Reputation Lists",
        "ScheduleExpression": "rate(1 hour)",
        "Targets": [{
          "Arn": {
            "Fn::GetAtt": [
              "LambdaWAFReputationListsParserFunction",
              "Arn"
            ]
          },
          "Id": "LambdaWAFReputationListsParserFunction",
          "Input": {
            "Fn::Join": [
              "", [
                "{\"lists\":",
                "[{\"url\":\"https://www.spamhaus.org/drop/drop.txt\"},{\"url\":\"https://check.torproject.org/exit-addresses\",\"prefix\":\"ExitAddress \"},{\"url\":\"https://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt\"}]",
                ",\"logType\":\"alb\"",
                ",\"region\":\"", {
                  "Ref": "AWS::Region"
                }, "\",",
                "\"ipSetIds\": [",
                "\"", {
                  "Ref": "WAFReputationListsSet1"
                },
                "\",",
                "\"", {
                  "Ref": "WAFReputationListsSet2"
                },
                "\"",
                "]}"
              ]
            ]
          }
        }]
      }
    },
    "LambdaInvokePermissionReputationListsParser": {
      "Type": "AWS::Lambda::Permission",
      "Condition": "ReputationListsProtectionActivated",
      "DependsOn": ["LambdaWAFReputationListsParserFunction", "LambdaWAFReputationListsParserEventsRule"],
      "Properties": {
        "FunctionName": {
          "Ref": "LambdaWAFReputationListsParserFunction"
        },
        "Action": "lambda:InvokeFunction",
        "Principal": "events.amazonaws.com",
        "SourceArn": {
          "Fn::GetAtt": [
            "LambdaWAFReputationListsParserEventsRule",
            "Arn"
          ]
        }
      }
    },
    "LambdaRoleBadBot": {
      "Type": "AWS::IAM::Role",
      "Condition": "BadBotProtectionActivated",
      "Properties": {
        "AssumeRolePolicyDocument": {
          "Version": "2012-10-17",
          "Statement": [{
            "Effect": "Allow",
            "Principal": {
              "Service": ["lambda.amazonaws.com"]
            },
            "Action": ["sts:AssumeRole"]
          }]
        },
        "Path": "/",
        "Policies": [{
          "PolicyName": "WAFGetChangeToken",
          "PolicyDocument": {
            "Statement": [{
              "Effect": "Allow",
              "Action": "waf-regional:GetChangeToken",
              "Resource": "*"
            }]
          }
        }, {
          "PolicyName": "WAFGetAndUpdateIPSet",
          "PolicyDocument": {
            "Statement": [{
              "Effect": "Allow",
              "Action": [
                "waf-regional:GetIPSet",
                "waf-regional:UpdateIPSet"
              ],
              "Resource": {
                "Fn::Join": [
                  "", [
                    "arn:aws:waf-regional:", {
                      "Ref": "AWS::Region"
                    }, ":", {
                      "Ref": "AWS::AccountId"
                    },
                    ":ipset/", {
                      "Ref": "WAFBadBotSet"
                    }
                  ]
                ]
              }
            }]
          }
        }, {
          "PolicyName": "LogsAccess",
          "PolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [{
              "Effect": "Allow",
              "Action": ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
              "Resource": {
                "Fn::Join": [":", ["arn:aws:logs", {
                  "Ref": "AWS::Region"
                }, {
                  "Ref": "AWS::AccountId"
                }, "log-group:/aws/lambda/*"]]
              }
            }]
          }
        }, {
          "PolicyName": "CloudFormationAccess",
          "PolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [{
              "Effect": "Allow",
              "Action": "cloudformation:DescribeStacks",
              "Resource": {
                "Fn::Join": [
                  "", [
                    "arn:aws:cloudformation:", {
                      "Ref": "AWS::Region"
                    },
                    ":", {
                      "Ref": "AWS::AccountId"
                    },
                    ":stack/", {
                      "Ref": "AWS::StackName"
                    },
                    "/*"
                  ]
                ]
              }
            }]
          }
        }, {
          "PolicyName": "CloudWatchAccess",
          "PolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [{
              "Effect": "Allow",
              "Action": "cloudwatch:GetMetricStatistics",
              "Resource": "*"
            }]
          }
        }]
      }
    },
    "LambdaWAFBadBotParserFunction": {
      "Type": "AWS::Lambda::Function",
      "Condition": "BadBotProtectionActivated",
      "DependsOn": "LambdaRoleBadBot",
      "Properties": {
        "Description": "This lambda function will intercepts and inspects trap endpoint requests to extract its IP address, and then add it to an AWS WAF block list.",
        "Handler": "access-handler.lambda_handler",
        "Role": {
          "Fn::GetAtt": ["LambdaRoleBadBot", "Arn"]
        },
        "Code": {
          "S3Bucket": {
            "Fn::Join": ["-", [
              "solutions", {
                "Ref": "AWS::Region"
              }
            ]]
          },
          "S3Key": "aws-waf-security-automations/v2/access-handler.zip"
        },
        "Environment": {
          "Variables": {
            "IP_SET_ID_BAD_BOT": {
              "Ref": "WAFBadBotSet"
            },
            "SEND_ANONYMOUS_USAGE_DATA": {
              "Ref": "SendAnonymousUsageData"
            },
            "UUID": {
              "Fn::GetAtt": ["CreateUniqueID", "UUID"]
            },
            "REGION": {
              "Ref": "AWS::Region"
            },
            "LOG_TYPE": "alb"
          }
        },
        "Runtime": "python2.7",
        "MemorySize": "128",
        "Timeout": "300"
      }
    },
    "LambdaInvokePermissionBadBot": {
      "Type": "AWS::Lambda::Permission",
      "Condition": "BadBotProtectionActivated",
      "DependsOn": "LambdaWAFBadBotParserFunction",
      "Properties": {
        "FunctionName": {
          "Fn::GetAtt": ["LambdaWAFBadBotParserFunction", "Arn"]
        },
        "Action": "lambda:*",
        "Principal": "apigateway.amazonaws.com"
      }
    },
    "ApiGatewayBadBot": {
      "Type": "AWS::ApiGateway::RestApi",
      "Condition": "BadBotProtectionActivated",
      "Properties": {
        "Name": "Security Automations - WAF Bad Bot API",
        "Description": "API created by AWS WAF Security Automations CloudFormation template. This endpoint will be used to capture bad bots."
      }
    },
    "ApiGatewayBadBotResource": {
      "Type": "AWS::ApiGateway::Resource",
      "Condition": "BadBotProtectionActivated",
      "Properties": {
        "RestApiId": {
          "Ref": "ApiGatewayBadBot"
        },
        "ParentId": {
          "Fn::GetAtt": ["ApiGatewayBadBot", "RootResourceId"]
        },
        "PathPart": "{proxy+}"
      }
    },
    "ApiGatewayBadBotMethodRoot": {
      "Type": "AWS::ApiGateway::Method",
      "Condition": "BadBotProtectionActivated",
      "DependsOn": ["LambdaWAFBadBotParserFunction", "LambdaInvokePermissionBadBot", "ApiGatewayBadBot"],
      "Properties": {
        "RestApiId": {
          "Ref": "ApiGatewayBadBot"
        },
        "ResourceId": {
          "Fn::GetAtt": ["ApiGatewayBadBot", "RootResourceId"]
        },
        "HttpMethod": "ANY",
        "AuthorizationType": "NONE",
        "RequestParameters": {
          "method.request.header.X-Forwarded-For": false
        },
        "Integration": {
          "Type": "AWS_PROXY",
          "IntegrationHttpMethod": "POST",
          "Uri": {
            "Fn::Join": ["", [
              "arn:aws:apigateway:", {
                "Ref": "AWS::Region"
              },
              ":lambda:path/2015-03-31/functions/", {
                "Fn::GetAtt": ["LambdaWAFBadBotParserFunction", "Arn"]
              },
              "/invocations"
            ]]
          }
        }
      }
    },
    "ApiGatewayBadBotMethod": {
      "Type": "AWS::ApiGateway::Method",
      "Condition": "BadBotProtectionActivated",
      "DependsOn": ["LambdaWAFBadBotParserFunction", "LambdaInvokePermissionBadBot", "ApiGatewayBadBot"],
      "Properties": {
        "RestApiId": {
          "Ref": "ApiGatewayBadBot"
        },
        "ResourceId": {
          "Ref": "ApiGatewayBadBotResource"
        },
        "HttpMethod": "ANY",
        "AuthorizationType": "NONE",
        "RequestParameters": {
          "method.request.header.X-Forwarded-For": false
        },
        "Integration": {
          "Type": "AWS_PROXY",
          "IntegrationHttpMethod": "POST",
          "Uri": {
            "Fn::Join": ["", [
              "arn:aws:apigateway:", {
                "Ref": "AWS::Region"
              },
              ":lambda:path/2015-03-31/functions/", {
                "Fn::GetAtt": ["LambdaWAFBadBotParserFunction", "Arn"]
              },
              "/invocations"
            ]]
          }
        }
      }
    },
    "ApiGatewayBadBotDeployment": {
      "Type": "AWS::ApiGateway::Deployment",
      "Condition": "BadBotProtectionActivated",
      "DependsOn": "ApiGatewayBadBotMethod",
      "Properties": {
        "RestApiId": {
          "Ref": "ApiGatewayBadBot"
        },
        "Description": "CloudFormation Deployment Stage",
        "StageName": "CFDeploymentStage"
      }
    },
    "ApiGatewayBadBotStage": {
      "Type": "AWS::ApiGateway::Stage",
      "Condition": "BadBotProtectionActivated",
      "DependsOn": "ApiGatewayBadBotDeployment",
      "Properties": {
        "DeploymentId": {
          "Ref": "ApiGatewayBadBotDeployment"
        },
        "Description": "Production Stage",
        "RestApiId": {
          "Ref": "ApiGatewayBadBot"
        },
        "StageName": "ProdStage"
      }
    },
    "LambdaRoleCustomResource": {
      "Type": "AWS::IAM::Role",
      "Condition": "CreateWebACL",
      "DependsOn": "WAFWebACL",
      "Properties": {
        "AssumeRolePolicyDocument": {
          "Version": "2012-10-17",
          "Statement": [{
            "Effect": "Allow",
            "Principal": {
              "Service": ["lambda.amazonaws.com"]
            },
            "Action": ["sts:AssumeRole"]
          }]
        },
        "Path": "/",
        "Policies": [{
          "PolicyName": "S3Access",
          "PolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [{
              "Effect": "Allow",
              "Action": [
                "s3:CreateBucket",
                "s3:GetBucketLocation",
                "s3:GetBucketNotification",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:PutBucketNotification"
              ],
              "Resource": {
                "Fn::Join": ["", ["arn:aws:s3:::", {
                  "Ref": "AccessLogBucket"
                }]]
              }
            }]
          }
        }, {
          "Fn::If": ["ReputationListsProtectionActivated", {
            "PolicyName": "LambdaAccess",
            "PolicyDocument": {
              "Version": "2012-10-17",
              "Statement": [{
                "Effect": "Allow",
                "Action": "lambda:InvokeFunction",
                "Resource": {
                  "Fn::GetAtt": ["LambdaWAFReputationListsParserFunction", "Arn"]
                }
              }]
            }
          }, {
            "Ref": "AWS::NoValue"
          }]
        }, {
          "PolicyName": "WAFAccess",
          "PolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [{
              "Effect": "Allow",
              "Action": [
                "waf-regional:GetWebACL",
                "waf-regional:UpdateWebACL"
              ],
              "Resource": {
                "Fn::Join": ["", ["arn:aws:waf-regional:", {
                    "Ref": "AWS::Region"
                  }, ":", {
                    "Ref": "AWS::AccountId"
                  },
                  ":webacl/", {
                    "Ref": "WAFWebACL"
                  }
                ]]
              }
            }]
          }
        }, {
          "PolicyName": "WAFRuleAccess",
          "PolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [{
              "Effect": "Allow",
              "Action": [
                "waf-regional:GetRule",
                "waf-regional:GetIPSet",
                "waf-regional:UpdateIPSet",
                "waf-regional:UpdateWebACL"
              ],
              "Resource": {
                "Fn::Join": ["", ["arn:aws:waf-regional:", {
                    "Ref": "AWS::Region"
                  }, ":", {
                    "Ref": "AWS::AccountId"
                  },
                  ":rule/*"
                ]]
              }
            }]
          }
        }, {
          "PolicyName": "WAFIPSetAccess",
          "PolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [{
              "Effect": "Allow",
              "Action": [
                "waf-regional:GetIPSet",
                "waf-regional:UpdateIPSet"
              ],
              "Resource": {
                "Fn::Join": ["", ["arn:aws:waf-regional:", {
                    "Ref": "AWS::Region"
                  }, ":", {
                    "Ref": "AWS::AccountId"
                  },
                  ":ipset/*"
                ]]
              }
            }]
          }
        }, {
          "PolicyName": "WAFRateBasedRuleAccess",
          "PolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [{
              "Effect": "Allow",
              "Action": [
                "waf-regional:GetRateBasedRule",
                "waf-regional:CreateRateBasedRule",
                "waf-regional:DeleteRateBasedRule",
                "waf-regional:ListRateBasedRules",
                "waf-regional:UpdateWebACL"
              ],
              "Resource": {
                "Fn::Join": ["", ["arn:aws:waf-regional:", {
                    "Ref": "AWS::Region"
                  }, ":", {
                    "Ref": "AWS::AccountId"
                  },
                  ":ratebasedrule/*"
                ]]
              }
            }]
          }
        }, {
          "PolicyName": "CloudFormationAccess",
          "PolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [{
              "Effect": "Allow",
              "Action": "cloudformation:DescribeStacks",
              "Resource": {
                "Fn::Join": [
                  "", [
                    "arn:aws:cloudformation:", {
                      "Ref": "AWS::Region"
                    },
                    ":", {
                      "Ref": "AWS::AccountId"
                    },
                    ":stack/", {
                      "Ref": "AWS::StackName"
                    },
                    "/*"
                  ]
                ]
              }
            }]
          }
        }, {
          "PolicyName": "WAFGetChangeToken",
          "PolicyDocument": {
            "Statement": [{
              "Effect": "Allow",
              "Action": "waf-regional:GetChangeToken",
              "Resource": "*"
            }]
          }
        }, {
          "PolicyName": "LogsAccess",
          "PolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [{
              "Effect": "Allow",
              "Action": ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
              "Resource": {
                "Fn::Join": [":", ["arn:aws:logs", {
                  "Ref": "AWS::Region"
                }, {
                  "Ref": "AWS::AccountId"
                }, "log-group:/aws/lambda/*"]]
              }
            }]
          }
        }]
      }
    },
    "LambdaWAFCustomResourceFunction": {
      "Type": "AWS::Lambda::Function",
      "Condition": "CreateWebACL",
      "DependsOn": "LambdaRoleCustomResource",
      "Properties": {
        "Description": "This lambda function configures the Web ACL rules based on the features enabled in the CloudFormation template.",
        "Handler": "custom-resource.lambda_handler",
        "Role": {
          "Fn::GetAtt": ["LambdaRoleCustomResource", "Arn"]
        },
        "Code": {
          "S3Bucket": {
            "Fn::Join": ["-", [
              "solutions", {
                "Ref": "AWS::Region"
              }
            ]]
          },
          "S3Key": "aws-waf-security-automations/v4/custom-resource.zip"
        },
        "Runtime": "python2.7",
        "MemorySize": "128",
        "Timeout": "300"
      }
    },
    "WafWebAclRuleControler": {
      "Type": "Custom::WafWebAclRuleControler",
      "Condition": "CreateWebACL",
      "DependsOn": ["LambdaWAFCustomResourceFunction", "WAFWebACL"],
      "Properties": {
        "ServiceToken": {
          "Fn::GetAtt": ["LambdaWAFCustomResourceFunction", "Arn"]
        },
        "StackName": {
          "Ref": "AWS::StackName"
        },
        "WAFWebACL": {
          "Ref": "WAFWebACL"
        },
        "Region": {
          "Ref": "AWS::Region"
        },
        "LambdaWAFReputationListsParserFunction": {
          "Fn::If": ["ReputationListsProtectionActivated", {
            "Fn::GetAtt": ["LambdaWAFReputationListsParserFunction", "Arn"]
          }, {
            "Ref": "AWS::NoValue"
          }]
        },
        "WAFWhitelistSet": {
          "Ref": "WAFWhitelistSet"
        },
        "WAFBlacklistSet": {
          "Fn::If": ["LogParserActivated", {
            "Ref": "WAFBlacklistSet"
          }, {
            "Ref": "AWS::NoValue"
          }]
        },
        "WAFScansProbesSet": {
          "Fn::If": ["ScansProbesProtectionActivated", {
            "Ref": "WAFScansProbesSet"
          }, {
            "Ref": "AWS::NoValue"
          }]
        },
        "WAFReputationListsSet1": {
          "Fn::If": ["ReputationListsProtectionActivated", {
            "Ref": "WAFReputationListsSet1"
          }, {
            "Ref": "AWS::NoValue"
          }]
        },
        "WAFReputationListsSet2": {
          "Fn::If": ["ReputationListsProtectionActivated", {
            "Ref": "WAFReputationListsSet2"
          }, {
            "Ref": "AWS::NoValue"
          }]
        },
        "WAFBadBotSet": {
          "Fn::If": ["BadBotProtectionActivated", {
            "Ref": "WAFBadBotSet"
          }, {
            "Ref": "AWS::NoValue"
          }]
        },
        "AccessLogBucket": {
          "Fn::If": ["LogParserActivated", {
            "Ref": "AccessLogBucket"
          }, {
            "Ref": "AWS::NoValue"
          }]
        },
        "LambdaWAFLogParserFunction": {
          "Fn::If": ["LogParserActivated", {
            "Fn::GetAtt": ["LambdaWAFLogParserFunction", "Arn"]
          }, {
            "Ref": "AWS::NoValue"
          }]
        },
        "WAFWhitelistRule": {
          "Fn::If": ["CreateWebACL", {
            "Ref": "WAFWhitelistRule"
          }, {
            "Ref": "AWS::NoValue"
          }]
        },
        "WAFBlacklistRule": {
          "Fn::If": ["LogParserActivated", {
            "Ref": "WAFBlacklistRule"
          }, {
            "Ref": "AWS::NoValue"
          }]
        },
        "WAFScansProbesRule": {
          "Fn::If": ["LogParserActivated", {
            "Ref": "WAFScansProbesRule"
          }, {
            "Ref": "AWS::NoValue"
          }]
        },
        "WAFIPReputationListsRule1": {
          "Fn::If": ["ReputationListsProtectionActivated", {
            "Ref": "WAFIPReputationListsRule1"
          }, {
            "Ref": "AWS::NoValue"
          }]
        },
        "WAFIPReputationListsRule2": {
          "Fn::If": ["ReputationListsProtectionActivated", {
            "Ref": "WAFIPReputationListsRule2"
          }, {
            "Ref": "AWS::NoValue"
          }]
        },
        "WAFBadBotRule": {
          "Fn::If": ["BadBotProtectionActivated", {
            "Ref": "WAFBadBotRule"
          }, {
            "Ref": "AWS::NoValue"
          }]
        },
        "WAFSqlInjectionRule": {
          "Fn::If": ["SqlInjectionProtectionActivated", {
            "Ref": "WAFSqlInjectionRule"
          }, {
            "Ref": "AWS::NoValue"
          }]
        },
        "WAFXssRule": {
          "Fn::If": ["CrossSiteScriptingProtectionActivated", {
            "Ref": "WAFXssRule"
          }, {
            "Ref": "AWS::NoValue"
          }]
        },
        "SqlInjectionProtection": {
          "Ref": "SqlInjectionProtectionParam"
        },
        "CrossSiteScriptingProtection": {
          "Ref": "CrossSiteScriptingProtectionParam"
        },
        "ActivateHttpFloodProtection": {
          "Ref": "ActivateHttpFloodProtectionParam"
        },
        "ActivateScansProbesProtection": {
          "Ref": "ActivateScansProbesProtectionParam"
        },
        "ActivateReputationListsProtection": {
          "Ref": "ActivateReputationListsProtectionParam"
        },
        "ActivateBadBotProtection": {
          "Ref": "ActivateBadBotProtectionParam"
        },
        "RequestThreshold": {
          "Ref": "RequestThreshold"
        },
        "ErrorThreshold": {
          "Ref": "ErrorThreshold"
        },
        "WAFBlockPeriod": {
          "Ref": "WAFBlockPeriod"
        },
        "SendAnonymousUsageData": {
          "Ref": "SendAnonymousUsageData"
        },
        "UUID": {
          "Fn::GetAtt": ["CreateUniqueID", "UUID"]
        },
        "LOG_TYPE": "alb"
      }
    },
    "SolutionHelperRole": {
      "Type": "AWS::IAM::Role",
      "Properties": {
        "AssumeRolePolicyDocument": {
          "Version": "2012-10-17",
          "Statement": [{
            "Effect": "Allow",
            "Principal": {
              "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
          }]
        },
        "Path": "/",
        "Policies": [{
          "PolicyName": "Solution_Helper_Permissions",
          "PolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [{
              "Effect": "Allow",
              "Action": ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
              "Resource": {
                "Fn::Join": [":", ["arn:aws:logs", {
                  "Ref": "AWS::Region"
                }, {
                  "Ref": "AWS::AccountId"
                }, "log-group:/aws/lambda/*"]]
              }
            }]
          }
        }]
      }
    },
    "SolutionHelper": {
      "Type": "AWS::Lambda::Function",
      "DependsOn": "SolutionHelperRole",
      "Properties": {
        "Handler": "solution-helper.lambda_handler",
        "Role": {
          "Fn::GetAtt": [
            "SolutionHelperRole",
            "Arn"
          ]
        },
        "Description": "This lambda function executes generic common tasks to support this solution.",
        "Code": {
          "S3Bucket": {
            "Fn::Join": [
              "", [
                "solutions-", {
                  "Ref": "AWS::Region"
                }
              ]
            ]
          },
          "S3Key": "library/solution-helper/v1/solution-helper.zip"
        },
        "Runtime": "python2.7",
        "Timeout": "300"
      }
    },
    "CreateUniqueID": {
      "Type": "Custom::CreateUUID",
      "DependsOn": "SolutionHelper",
      "Properties": {
        "ServiceToken": {
          "Fn::GetAtt": [
            "SolutionHelper",
            "Arn"
          ]
        },
        "Region": {
          "Ref": "AWS::Region"
        },
        "CreateUniqueID": "true"
      }
    }
  },
  "Outputs": {
    "BadBotHoneypotEndpoint": {
      "Description": "Bad Bot Honeypot Endpoint",
      "Value": {
        "Fn::Join": ["", [
          "https://", {
            "Ref": "ApiGatewayBadBot"
          },
          ".execute-api.", {
            "Ref": "AWS::Region"
          },
          ".amazonaws.com/", {
            "Ref": "ApiGatewayBadBotStage"
          }
        ]]
      },
      "Condition": "BadBotProtectionActivated"
    },
    "WAFWebACL": {
      "Description": "AWS WAF WebACL ID",
      "Value": {
        "Ref": "WAFWebACL"
      },
      "Condition": "CreateWebACL"
    }
  }
}
STACK
}