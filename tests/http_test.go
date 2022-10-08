package test

import (
	"crypto/tls"
	"fmt"
	"strings"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestHttp(t *testing.T) {
	t.Parallel()
	repoPath := ".."
	varFiles := retrieveVarFiles(t)
	timestamp := createTimestamp()

	testCases := []*struct {
		name     string
		url      string
		expected string
	}{
		{
			name:     "grpc",
			url:      "https://nextjs-grpc.utkusarioglu.com/grpc:4430",
			expected: "Your name is utku, you are 3 years old, you are a teacher",
		},
		{
			name:     "home",
			url:      "https://nextjs-grpc.utkusarioglu.com:4430",
			expected: "rocket",
		},
		{
			name:     "Grafana",
			url:      "https://grafana.nextjs-grpc.utkusarioglu.com/login:4430",
			expected: "Grafana Labs",
		},
		{
			name:     "Jaeger",
			url:      "https://jaeger.nextjs-grpc.utkusarioglu.com/search:4430",
			expected: "Jaeger UI",
		},
	}

	test_structure.RunTestStage(t, "setup", func() {
		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: repoPath,
			VarFiles:     varFiles,
			EnvVars: map[string]string{
				"TF_LOG_PATH": fmt.Sprintf("logs/%s.terratest.log", timestamp),
				"TF_LOG":      "DEBUG",
			},
		})
		test_structure.SaveTerraformOptions(t, ".", terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		t.Run("group", func(t *testing.T) {
			for _, testCase := range testCases {
				testCase := testCase
				t.Run(testCase.name, func(t *testing.T) {
					t.Parallel()
					validateResponse := func(status_code int, response_text string) bool {
						return strings.Contains(response_text, testCase.expected)
					}

					tls_config := &tls.Config{
						InsecureSkipVerify: true,
					}

					http_helper.HttpGetWithRetryWithCustomValidation(
						t,
						testCase.url,
						tls_config,
						5,
						5*time.Second,
						validateResponse,
					)
				})
			}
		})
	})

	test_structure.RunTestStage(t, "teardown", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, ".")
		terraform.Destroy(t, terraformOptions)
	})
}
