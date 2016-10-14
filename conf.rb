AMOUNT_CPU = 1

AMOUNT_WORKERS = AMOUNT_CPU

MAX_PACKET = 32768

HOST = 'localhost'
PORT = 8080


STATUS_DICT = {
    '200': 'OK',
    '403': 'Forbidden',
    '404': 'Not Found',
    '405': 'Method Not Allowed',
    '501': 'Method Not Implemented'
}

CONTENT_TYPE_MAPPING = {
    'css' => 'text/css',
    'js' => 'text/javascript',
    'jpeg' => 'image/jpeg',
    'gif' => 'image/gif',
    'swf' => 'application/x-shockwave-flash',
    'html' => 'text/html',
    'txt' => 'text/plain',
    'png' => 'image/png',
    'jpg' => 'image/jpeg'
}

ALLOW_METHODS = ['GET', 'HEAD'].join(', ')

PROJECT_ROOT = 'DOCUMENT_ROOT'
INDEX_PATH = 'index.html'

DEFAULT_CONTENT_TYPE = 'text/plain'

PROTOCOL = 'HTTP/1.1'
SERVER_NAME = 'Marina\'s server'
CONNECTION_TOKEN = 'close'
HTTP_DATE_FORMAT = '%a, %d %b %Y %H:%M:%S GMT'