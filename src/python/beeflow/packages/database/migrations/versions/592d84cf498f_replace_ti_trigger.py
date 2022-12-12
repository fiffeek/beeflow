#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

"""replace ti trigger

Revision ID: 592d84cf498f
Revises: 36933d146b0e
Create Date: 2022-12-12 21:36:45.964500

"""

import sqlalchemy as sa
from alembic import op


# revision identifiers, used by Alembic.
revision = '592d84cf498f'
down_revision = '36933d146b0e'
branch_labels = None
depends_on = None


def upgrade():
    """Apply replace ti trigger"""
    conn = op.get_bind()
    conn.execute("DROP TRIGGER IF EXISTS upsert_ti_trigger ON task_instance;")
    conn.execute("""
    CREATE TRIGGER upsert_ti_trigger
      AFTER UPDATE ON task_instance
      FOR EACH ROW
      WHEN (NEW.state = 'scheduled' OR NEW.state = 'queued' OR NEW.state = 'success' OR NEW.STATE = 'failed' OR NEW.state = 'skipeed' OR NEW.state = 'upstream_failed' OR NEW.state = 'up_for_retry' OR NEW.state = 'up_for_reschedule' OR NEW.state = 'stopped' OR NEW.state = 'removed')
      EXECUTE PROCEDURE passthrough_all_data();
        """)


def downgrade():
    """Unapply replace ti trigger"""
    pass
