import os
import subprocess
import requests
import getpass
import shutil

# Configuration
GITHUB_ORG = 'srk-ullagallu'  # Replace with your GitHub organization name
GITHUB_TOKEN = getpass.getpass('Enter your GitHub Personal Access Token: ')
SOURCE_REPO = f'https://github.com/{GITHUB_ORG}/ibm-instana.git'  # Ensure this is correctly formatted

def create_github_repo(repo_name):
    """
    Creates a new GitHub repository in the specified organization.
    
    :param repo_name: Name of the repository to create.
    :return: True if the repository was created successfully, otherwise False.
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
        return True
    else:
        print(f'Failed to create repository: {GITHUB_ORG}/{repo_name}')
        print(f'Status code: {response.status_code}')
        try:
            print(f'Message: {response.json()}')
        except ValueError:
            print("No JSON message in response")
        return False

def extract_service_and_push(service_name):
    """
    Extracts the specified service from the monorepo and pushes it to a new GitHub repository.
    
    :param service_name: The name of the service to extract.
    """
    # Clone the source repository
    subprocess.run(f'git clone {SOURCE_REPO} ibm-instana', shell=True, check=True)
    
    # Create a new directory for the service
    os.makedirs(service_name, exist_ok=True)

    # Move the service folder to the new directory while preserving the structure
    service_path = os.path.join('ibm-instana', service_name)
    
    if os.path.exists(service_path):
        shutil.move(service_path, service_name)
    else:
        print(f'Service {service_name} does not exist in the repository. Skipping...')
        shutil.rmtree('ibm-instana')  # Clean up cloned repo
        return

    # Change to the new service directory
    os.chdir(service_name)
    
    # Initialize a new Git repository
    subprocess.run('git init', shell=True, check=True)
    
    # Add the remote repository URL
    new_repo_url = f'https://{GITHUB_TOKEN}@github.com/{GITHUB_ORG}/{service_name}.git'
    subprocess.run(f'git remote add origin {new_repo_url}', shell=True, check=True)
    
    # Add files, commit and push to the new repository
    subprocess.run('git add .', shell=True, check=True)
    subprocess.run(f'git commit -m "Migrated {service_name} service from ibm-instana"', shell=True, check=True)
    subprocess.run('git push -u origin master', shell=True, check=True)
    
    print(f'Successfully pushed {service_name} to the new repository.')
    
    # Clean up: go back to the original directory and remove the cloned repository
    os.chdir('..')
    shutil.rmtree('ibm-instana')

# List of services to extract and create repositories for
services_to_extract = [
    'catalogue',
    'user',
    'cart',
    'shipping',
    'payment',
    'frontend'
]

# Iterate over the list of services
for service in services_to_extract:
    extract_service_and_push(service)
