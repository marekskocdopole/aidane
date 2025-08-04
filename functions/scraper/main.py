import base64

def process_document_change(event, context=None):
    """Triggered from a message on a Cloud Pub/Sub topic.
    Args:
         event (dict): Event payload.
         context (google.cloud.functions.Context): Metadata for the event.
    """
    pubsub_message = base64.b64decode(event.get_json()['data']).decode('utf-8')
    print(f"Přijata zpráva o změně: {pubsub_message}")
    return "OK", 200
