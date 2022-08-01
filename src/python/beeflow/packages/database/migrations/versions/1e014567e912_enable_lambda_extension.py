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

"""enable lambda extension

Revision ID: 1e014567e912
Revises: 3c94c427fdf6
Create Date: 2022-08-01 23:15:51.073160

"""

import sqlalchemy as sa
from alembic import op


# revision identifiers, used by Alembic.
revision = '1e014567e912'
down_revision = '3c94c427fdf6'
branch_labels = None
depends_on = None


def upgrade():
    """Apply enable lambda extension"""
    conn = op.get_bind()
    conn.execute("CREATE EXTENSION IF NOT EXISTS aws_lambda CASCADE;")


def downgrade():
    """Unapply enable lambda extension"""
    pass
