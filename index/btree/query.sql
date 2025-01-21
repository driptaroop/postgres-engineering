select process_id, process_type, mfa_id, mfa_expiry
from process
where process_status = 'initialized'
  and mfa_status in ('authorized', 'created')
order by process_time asc
limit 100;