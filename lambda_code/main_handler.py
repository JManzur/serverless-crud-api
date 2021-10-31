from crud_functions import create_function, read_function, update_function, delete_function
from botocore.exceptions import ClientError
import boto3
import json
import sys
import logging
import traceback

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Instantiating DynamoDB connection objects:
dynamodb = boto3.resource('dynamodb')
client = boto3.client('dynamodb')
project_table = dynamodb.Table('ServerlessCRUD-Table')

def lambda_handler(event, context):
    try:
        # CREATE-POST:
        if event['http_method'] == 'POST':
            CustomerId = event['CustomerId']
            FirstName = event['FirstName']
            LastName = event['LastName']
            try:
                return create_function(project_table, CustomerId, FirstName, LastName)
            except ClientError as e:
                logger.error(e)
                if e.response['Error']['Code'] == 'ConditionalCheckFailedException':
                    return {
                        'statusCode': 403,
                        'headers': {'Content-Type': 'application/json'},
                        'body': {
                            'Warning': 'DUPLICATE: Object with ID: {0} already exists'.format(CustomerId),
                            'Operation': '{}'.format(event['http_method']),
                            'moreInfo': {
                                'Lambda Request ID': '{}'.format(context.aws_request_id),
                                'CloudWatch log stream name': '{}'.format(context.log_stream_name),
                                'CloudWatch log group name': '{}'.format(context.log_group_name)
                            },
                        },
                    }
                else:
                    return {
                        'statusCode': 500,
                        'headers': {'Content-Type': 'application/json'},
                        'body': {
                            'Error': 'Sorry an error has occurred',
                            'Operation': '{}'.format(event['http_method']),
                            'moreInfo': {
                                'Lambda Request ID': '{}'.format(context.aws_request_id),
                                'CloudWatch log stream name': '{}'.format(context.log_stream_name),
                                'CloudWatch log group name': '{}'.format(context.log_group_name)
                            },
                        },
                    }

        # READ-GET:
        elif event['http_method'] == 'GET':
            CustomerId = event['CustomerId']

            try:
                return read_function(project_table, CustomerId)
            except Exception as e:
                logger.error("An error occured while reading the table")
                logger.error(e)
                return {
                    'statusCode': 500,
                    'headers': {'Content-Type': 'application/json'},
                    'body': {
                        'Error': 'Sorry an error has occurred',
                        'Operation': '{}'.format(event['http_method']),
                        'moreInfo': {
                            'Lambda Request ID': '{}'.format(context.aws_request_id),
                            'CloudWatch log stream name': '{}'.format(context.log_stream_name),
                            'CloudWatch log group name': '{}'.format(context.log_group_name)
                        },
                    },
                }

        # UPDATE-PUT:
        elif event['http_method'] == 'PUT':
            CustomerId = event['CustomerId']
            try:
                return update_function(project_table, CustomerId, event)
            except ClientError as e:
                logger.error(e)
                if e.response['Error']['Code'] == 'ConditionalCheckFailedException':
                    logger.error("object with ID: {0} does not exist".format(CustomerId))
                    return {
                        'statusCode': 404,
                        'headers': {'Content-Type': 'application/json'},
                        'body': {
                            'Error': 'NOT FOUND: object with ID: {0} does not exist'.format(CustomerId),
                            'Operation': '{}'.format(event['http_method']),
                            'moreInfo': {
                                'Lambda Request ID': '{}'.format(context.aws_request_id),
                                'CloudWatch log stream name': '{}'.format(context.log_stream_name),
                                'CloudWatch log group name': '{}'.format(context.log_group_name)
                            },
                        },
                    }
                else:
                    return {
                        'statusCode': 500,
                        'headers': {'Content-Type': 'application/json'},
                        'body': {
                            'Error': 'Sorry an error has occurred',
                            'Operation': '{}'.format(event['http_method']),
                            'moreInfo': {
                                'Lambda Request ID': '{}'.format(context.aws_request_id),
                                'CloudWatch log stream name': '{}'.format(context.log_stream_name),
                                'CloudWatch log group name': '{}'.format(context.log_group_name)
                            },
                        },
                    }

        # DELETE-DELETE:
        elif event['http_method'] == 'DELETE':
            CustomerId = event['CustomerId']
            try:
                return delete_function(project_table, CustomerId)
            except ClientError as e:
                logger.error(e)
                if e.response['Error']['Code'] == 'ConditionalCheckFailedException':
                    return {
                        'statusCode': 404,
                        'headers': {'Content-Type': 'application/json'},
                        'body': {
                            'Error': 'NOT FOUND: object with ID: {0} does not exist'.format(CustomerId),
                            'Operation': '{}'.format(event['http_method']),
                            'moreInfo': {
                                'Lambda Request ID': '{}'.format(context.aws_request_id),
                                'CloudWatch log stream name': '{}'.format(context.log_stream_name),
                                'CloudWatch log group name': '{}'.format(context.log_group_name)
                                },
                            },
                        }
                    
                else:
                    logger.error("An error occured while reading the table")
                    return {
                        'statusCode': 500,
                        'headers': {'Content-Type': 'application/json'},
                        'body': {
                            'Error': 'Sorry an error has occurred',
                            'Operation': '{}'.format(event['http_method']),
                            'moreInfo': {
                                'Lambda Request ID': '{}'.format(context.aws_request_id),
                                'CloudWatch log stream name': '{}'.format(context.log_stream_name),
                                'CloudWatch log group name': '{}'.format(context.log_group_name)
                            },
                        },
                    }

        # Bad Request:
        else:
            return {
                'statusCode': 400,
                'headers': {'Content-Type': 'application/json'},
                'body': {
                    'Error': 'Bad Request',
                    'Operation': '{}'.format(event['http_method']),
                    'moreInfo': {
                        'Lambda Request ID': '{}'.format(context.aws_request_id),
                        'CloudWatch log stream name': '{}'.format(context.log_stream_name),
                        'CloudWatch log group name': '{}'.format(context.log_group_name)
                    },
                },
            }

    # Lambda error handler:
    except Exception as e:
        exception_type, exception_value, exception_traceback = sys.exc_info()
        traceback_string = traceback.format_exception(
            exception_type, exception_value, exception_traceback)
        err_msg = json.dumps({
            "errorType": exception_type.__name__,
            "errorMessage": str(exception_value),
            "stackTrace": traceback_string
        })
        logger.error(err_msg)
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': {
                'Error': 'Sorry an error has occurred',
                'Operation': '{}'.format(event['http_method']),
                'moreInfo': {
                    'Lambda Request ID': '{}'.format(context.aws_request_id),
                    'CloudWatch log stream name': '{}'.format(context.log_stream_name),
                    'CloudWatch log group name': '{}'.format(context.log_group_name)
                },
            },
        }
