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

"""trigger event on task instance creation or update

Revision ID: a7836d0f25b8
Revises: b3df883b80f3
Create Date: 2022-09-04 21:02:15.493670

"""

import sqlalchemy as sa
from alembic import op


# revision identifiers, used by Alembic.
revision = 'a7836d0f25b8'
down_revision = 'b3df883b80f3'
branch_labels = None
depends_on = None


def generate_passthrough_all() -> str:
    return """CONCAT('{"metadata":', row_to_json(NEW.*), '}')"""


def upgrade():
    """Apply trigger event on task instance creation or update"""
    conn = op.get_bind()
    conn.execute(f"""
CREATE OR REPLACE FUNCTION passthrough_all_data()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
  AS
$$
BEGIN
   PERFORM * FROM aws_lambda.invoke(aws_commons.create_lambda_function_arn('beeflow-dev-cdc-forwarder', 'us-east-2'),
                                    {generate_passthrough_all()}::json,
                                    'Event');
    RETURN NEW;
END
$$
    """)
    conn.execute("DROP TRIGGER IF EXISTS upsert_ti_trigger ON task_instance;")
    conn.execute("""
CREATE TRIGGER upsert_ti_trigger
  AFTER INSERT OR UPDATE ON task_instance
  FOR EACH ROW
  EXECUTE PROCEDURE passthrough_all_data();
    """)


def downgrade():
    """Unapply trigger event on task instance creation or update"""
    pass
