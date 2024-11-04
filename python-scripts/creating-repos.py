import requests
import getpass

# Configuration
GITHUB_ORG = 'srk-ullagallu'
GITHUB_TOKEN = getpass.getpass('Enter your GitHub Personal Access Token: ')

def create_github_org_repo(repo_name):
    """
    Creates a repository in a GitHub organization.
    
    :param repo_name: Name of the repository to create (e.g., 'repo-name').
    """
    url = f'https://api.github.com/orgs/{GITHUB_ORG}/repos'
    headers = {
        'Authorization': f'token {GITHUB_TOKEN}',
        'Accept': 'application/vnd.github.v3+json'
    }
    data = {
        'name': repo_name,
        'private': False  # Set to True if you want to create private repositories
    }
    
    response = requests.post(url, headers=headers, json=data)
    
    if response.status_code == 201:
        print(f'Successfully created repository: {GITHUB_ORG}/{repo_name}')
    else:
        print(f'Failed to create repository: {GITHUB_ORG}/{repo_name}')
        print(f'Status code: {response.status_code}')
        try:
            print(f'Message: {response.json()}')
        except ValueError:
            print("No JSON message in response")

# List of repositories to create
repos_to_create = [
    'catalogue', 'user', 'cart', 'shipping' ,'payment', 'frontend'
]

# Loop through each repository name and create it
for repo in repos_to_create:
    create_github_org_repo(repo)
