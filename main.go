package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"time"
)

func main() {
	url := "https://api2.authorize.net/xml/v1/request.api"

	client := http.Client{
		Transport: &http.Transport{

			// Max idle search connections available for reuse.
			MaxIdleConnsPerHost: 2,
		},

		// Set timeout to prevent bottlenecks if the search server is struggling.
		Timeout: 10000 * time.Second,
	}

	// Create the HTTP GET request
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error creating request: %v\n", err)
		os.Exit(1)
	}

	// Add headers if needed
	req.Header.Set("User-Agent", "Go-HTTP-Client/1.1")

	// Perform the request
	resp, err := client.Do(req)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error making GET request: %v\n", err)
		os.Exit(1)
	}
	defer resp.Body.Close()

	// Check for a successful response
	if resp.StatusCode != http.StatusOK {
		fmt.Fprintf(os.Stderr, "Unexpected status code: %d\n", resp.StatusCode)
		os.Exit(1)
	}

	// Read and print the response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error reading response body: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Response body:\n%s\n", body)
}
