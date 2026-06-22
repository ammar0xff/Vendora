import sys, os
sys.path.insert(0, '/app')
os.environ['DONE_DIR'] = '/tmp'
exec(open('/tmp/update_rock_prices_db.py').read().replace("DONE_DIR = os.path.join(os.path.dirname(__file__), 'done')", "DONE_DIR = '/tmp'"))
