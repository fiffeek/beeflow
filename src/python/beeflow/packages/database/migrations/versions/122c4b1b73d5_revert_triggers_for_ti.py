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

"""revert triggers for ti

Revision ID: 122c4b1b73d5
Revises: 592d84cf498f
Create Date: 2022-12-12 23:42:54.166727

"""

import sqlalchemy as sa
from alembic import op


# revision identifiers, used by Alembic.
revision = '122c4b1b73d5'
down_revision = '592d84cf498f'
branch_labels = None
depends_on = None


def upgrade():
    """Apply trigger event on task instance creation or update"""
    conn = op.get_bind()
    conn.execute("DROP TRIGGER IF EXISTS upsert_ti_trigger ON task_instance;")
    conn.execute("""
    CREATE TRIGGER upsert_ti_trigger
      AFTER INSERT OR UPDATE ON task_instance
      FOR EACH ROW
      EXECUTE PROCEDURE passthrough_all_data();
        """)


def downgrade():
    """Unapply revert triggers for ti"""
    pass
