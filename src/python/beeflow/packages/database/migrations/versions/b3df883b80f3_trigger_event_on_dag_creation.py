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

"""trigger event on dag creation

Revision ID: b3df883b80f3
Revises: 1e014567e912
Create Date: 2022-08-07 12:29:44.510068

"""

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision = 'b3df883b80f3'
down_revision = '1e014567e912'
branch_labels = None
depends_on = None


def generate_dag_created_json_string() -> str:
    return '{"metadata": {"event_type": "dag_created", "dag_id": NEW.dag_id}}'


def upgrade():
    """Apply trigger event on dag creation"""
    conn = op.get_bind()
    conn.execute(f"""
CREATE OR REPLACE FUNCTION dag_created_trigger()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
  AS
$$
BEGIN
   PERFORM * FROM aws_lambda.invoke(aws_commons.create_lambda_function_arn('beeflow-dev-cdc-forwarder', 'us-east-2'),
                                    '{generate_dag_created_json_string()}'::json,
                                    'Event');
    RETURN NEW;
END
$$
""")
    conn.execute("DROP TRIGGER IF EXISTS new_dag_trigger ON dag;")
    conn.execute("""
CREATE TRIGGER new_dag_trigger
  AFTER INSERT ON dag
  FOR EACH ROW
  EXECUTE PROCEDURE dag_created_trigger();
""")


def downgrade():
    """Unapply trigger event on dag creation"""
    pass
