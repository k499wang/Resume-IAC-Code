import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Cloud-Resume-Database')

def lambda_handler(event, context):
    # Retrieve user IP address from headers
    user_ip = event['headers'].get('x-forwarded-for')

    # Check if the IP already exists in the database with a different ID (e.g., '2')
    ip_response = table.get_item(Key={'id': '2'})
    ip_list = ip_response.get('Item', {}).get('ips', [])

    if user_ip not in ip_list:
        # If IP is unique, increment views and add IP to the list
        views_response = table.get_item(Key={'id': '1'})
        views = views_response['Item']['views'] + 1

        # Update views count in the database
        table.put_item(Item={'id': '1', 'views': views})

        # Add new IP to the IP list and update in the database
        ip_list.append(user_ip)
        table.put_item(Item={'id': '2', 'ips': ip_list})

    else:
        # If IP is not unique, get the current view count without incrementing
        views = table.get_item(Key={'id': '1'})['Item']['views']

    return {
        'statusCode': 200,
        'body': json.dumps(views)
    }
