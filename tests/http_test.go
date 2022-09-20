package test

import (
	"crypto/tls"
	"strings"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestHttp(t *testing.T) {
	t.Parallel()
	repoPath := ".."

	testCases := []*struct {
		name     string
		url      string
		expected string
	}{
		{
			name:     "grpc",
			url:      "https://nextjs-grpc.utkusarioglu.com/grpc",
			expected: "Your name is utku, you are 3 years old, you are a teacher",
		},
		{
			name:     "home",
			url:      "https://nextjs-grpc.utkusarioglu.com",
			expected: "rocket",
		},
	}

	test_structure.RunTestStage(t, "setup", func() {
		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: repoPath,
		})

		// test_structure.SaveTerraformOptions(t, repoPath, terraformOptions)

		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		t.Run("group", func(t *testing.T) {
			for _, testCase := range testCases {
				// To avoid the range variable from getting updated in the parallel tests, we bind a new name that is within
				// the scope of the for block.
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
		// terraformOptions := test_structure.LoadTerraformOptions(t, repoPath)
		terraform.Destroy(t, &terraform.Options{
			TerraformDir: repoPath,
			Logger:       logger.Discard,
		})
	})
}
