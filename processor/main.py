from google.cloud import storage, pubsub_v1
import os

def process_raw_document(event, context):
    """Triggered by a change to a Cloud Storage bucket.
    Args:
         event (dict): Event payload.
         context (google.cloud.functions.Context): Metadata for the event.
    """
    # Get file and bucket details from the event
    bucket_name = event['bucket']
    file_name = event['name']
    
    print(f"Zpracovávám soubor {file_name} z bucketu {bucket_name}.")

    # Simulate processing
    processed_content = f"Obsah souboru {file_name} byl zpracován."
    processed_file_name = f"processed-{file_name}"

    # Get the target bucket name from environment variables
    # We will set this in Terraform
    target_bucket_name = os.environ.get('PROCESSED_BUCKET_NAME')
    if not target_bucket_name:
        raise ValueError("PROCESSED_BUCKET_NAME environment variable not set.")

    # Upload the processed content to the target bucket
    storage_client = storage.Client()
    target_bucket = storage_client.bucket(target_bucket_name)
    target_blob = target_bucket.blob(processed_file_name)
    target_blob.upload_from_string(processed_content)
    
    print(f"Zpracovaný soubor '{processed_file_name}' nahrán do bucketu '{target_bucket_name}'.")

    # Get the target topic name from environment variables
    # We will set this in Terraform
    target_topic_name = os.environ.get('FINISHED_TOPIC_NAME')
    project_id = os.environ.get('GCP_PROJECT')
    if not target_topic_name or not project_id:
        raise ValueError("FINISHED_TOPIC_NAME or GCP_PROJECT environment variables not set.")

    # Publish a message to the "processing-finished" topic
    publisher = pubsub_v1.PublisherClient()
    topic_path = publisher.topic_path(project_id, target_topic_name)
    message_data = processed_file_name.encode('utf-8')
    future = publisher.publish(topic_path, data=message_data)
    future.result()  # Wait for the publish to complete

    print(f"Zpráva o dokončení zpracování souboru '{processed_file_name}' byla odeslána do tématu '{target_topic_name}'.")
