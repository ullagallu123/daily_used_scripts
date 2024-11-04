import os
import shutil
import subprocess
import getpass

# Configuration
SOURCE_REPO = 'https://github.com/srk-ullagallu/ibm-instana.git'  # Source repo
GITHUB_ORG = 'srk-ullagallu'  # GitHub organization
GITHUB_TOKEN = getpass.getpass('Enter your GitHub Personal Access Token: ')

# List of services to create repositories for
services_to_migrate = [
    'catalogue',
    'user',
    'cart',
    'shipping',
    'payment',
    'frontend'
]

def extract_service_and_push(service_name):
    """
    Extract a service from the monorepo and push it to a new repository.
    
    :param service_name: Name of the service to extract and migrate.
    """
    # Check if the ibm-instana directory already exists and remove it if it does
    if os.path.exists('ibm-instana'):
        shutil.rmtree('ibm-instana')

    # Clone the source repository
    try:
        subprocess.run(f'git clone {SOURCE_REPO} ibm-instana', shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Failed to clone repository: {e}")
        return

    # Create a new directory for the service
    os.makedirs(service_name, exist_ok=True)

    # Move the service folder to the new directory while preserving the structure
    service_path = os.path.join('ibm-instana', service_name)
    
    if os.path.exists(service_path):
        shutil.move(service_path, service_name)
    else:
        print(f'Service {service_name} does not exist in the repository. Skipping...')
        return

    # Change to the new service directory
    os.chdir(service_name)
    
    # Initialize a new Git repository
    subprocess.run('git init', shell=True, check=True)
    
    # Configure user identity for the repository
    subprocess.run('git config user.name "ullagall123"', shell=True, check=True)  # Replace with your name
    subprocess.run('git config user.email "sivaram0434@gmail.com"', shell=True, check=True)  # Replace with your email

    # Add the remote repository URL
    new_repo_url = f'https://{GITHUB_TOKEN}@github.com/{GITHUB_ORG}/{service_name}.git'
    subprocess.run(f'git remote add origin {new_repo_url}', shell=True, check=True)
    
    # Create the initial commit on the main branch
    subprocess.run('git add .', shell=True, check=True)
    subprocess.run(f'git commit -m "Initial commit for {service_name} service"', shell=True, check=True)

    # Create the main branch
    subprocess.run('git branch -m main', shell=True, check=True)

    # Push to the new repository on the main branch
    try:
        subprocess.run('git push -u origin main', shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Failed to push {service_name} to the new repository: {e}")
    
    print(f'Successfully pushed {service_name} to the new repository.')
    
    # Clean up: go back to the original directory and remove the cloned repository
    os.chdir('..')
    shutil.rmtree('ibm-instana')

def main():
    # Loop through each service and extract/push
    for service in services_to_migrate:
        extract_service_and_push(service)

if __name__ == '__main__':
    main()
