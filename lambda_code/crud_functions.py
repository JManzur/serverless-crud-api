import json
import logging
from decimal import Decimal

logger = logging.getLogger()
logger.setLevel(logging.INFO)

#CREATE - POST
def create_function(project_table, CustomerId, FirstName, LastName):
    project_table.put_item(
        Item={
            'CustomerId': int(CustomerId),
            'FirstName': FirstName,
            'LastName': LastName
        },
        ConditionExpression='attribute_not_exists(CustomerId)'
    )
    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': {
            'message': 'Records successfully created'
        }
    }

#READ - GET
def read_function(project_table, CustomerId):
    response = project_table.get_item(Key={'CustomerId': int(CustomerId)})
    dynamo_resp = json.dumps(response, cls=DecimalEncoder)
    logger.info("DynamoDB Response: {}".format(dynamo_resp))

    if 'Item' in response:
        logger.info("Customer ID match found!")
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': {
                'CustomerId': '{}'.format(CustomerId),
                'FirstName': '{}'.format(response['Item']['FirstName']),
                'LastName': '{}'.format(response['Item']['LastName'])
            }
        }

    else:
        return {
            'statusCode': 404,
            'headers': {'Content-Type': 'application/json'},
            'body': {
                'message': 'Customer ID not found',
                'DynamoDB Response:': '{}'.format(dynamo_resp)
            }
        }

#UPDATE - PUT
def update_function(project_table, CustomerId, event):
    if 'FirstName' in event and 'LastName' not in event:
        FirstName = event['FirstName']
        UpdateExpression = 'SET FirstName = :val1'
        ExpressionAttributeValues = {
            ':val1': FirstName
            }

    elif 'LastName' in event and 'FirstName' not in event:
        LastName = event['LastName']
        UpdateExpression = 'SET LastName = :val1'
        ExpressionAttributeValues = {
            ':val1': LastName
            }

    elif 'FirstName' in event and 'LastName' in event:
        LastName = event['LastName']
        FirstName = event['FirstName']
        UpdateExpression = 'SET LastName = :val1, FirstName = :val2'
        ExpressionAttributeValues = {
            ':val1': LastName,
            ':val2': FirstName
        }
    else:
        raise ValueError("FirstName and LastName not given")

    project_table.update_item(
        Key={
            'CustomerId': int(CustomerId)
        },
        ConditionExpression='attribute_exists(CustomerId)',
        UpdateExpression=UpdateExpression,
        ExpressionAttributeValues=ExpressionAttributeValues
    )
    return {
        'statusCode': 201,
        'headers': {'Content-Type': 'application/json'},
        'body': {
            'message': 'Records successfully updated'
        }
    }

#DELETE - DELETE
def delete_function(project_table, CustomerId):
    project_table.delete_item(
        Key={
            'CustomerId': int(CustomerId)
        },
        ConditionExpression="attribute_exists(CustomerId)"
    )
    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': {
            'message': 'Records successfully deleted'
        }
    }

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return str(obj)
        return json.JSONEncoder.default(self, obj)
