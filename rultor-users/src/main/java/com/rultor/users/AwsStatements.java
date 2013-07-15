/**
 * Copyright (c) 2009-2013, rultor.com
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met: 1) Redistributions of source code must retain the above
 * copyright notice, this list of conditions and the following
 * disclaimer. 2) Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following
 * disclaimer in the documentation and/or other materials provided
 * with the distribution. 3) Neither the name of the rultor.com nor
 * the names of its contributors may be used to endorse or promote
 * products derived from this software without specific prior written
 * permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT
 * NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package com.rultor.users;

import com.amazonaws.services.dynamodbv2.model.AttributeValue;
import com.jcabi.aspects.Immutable;
import com.jcabi.aspects.Loggable;
import com.jcabi.dynamo.Attributes;
import com.jcabi.dynamo.Conditions;
import com.jcabi.dynamo.Item;
import com.jcabi.dynamo.QueryValve;
import com.jcabi.dynamo.Region;
import com.jcabi.urn.URN;
import com.rultor.spi.Dollars;
import com.rultor.spi.Statement;
import com.rultor.spi.Statements;
import com.rultor.spi.Time;
import java.util.Iterator;
import lombok.EqualsAndHashCode;
import lombok.ToString;

/**
 * Statements in DynamoDB.
 *
 * @author Yegor Bugayenko (yegor@tpc2.com)
 * @version $Id$
 * @since 1.0
 */
@Immutable
@ToString
@EqualsAndHashCode(of = { "region", "name" })
@Loggable(Loggable.DEBUG)
final class AwsStatements implements Statements {

    /**
     * Dynamo DB table name.
     */
    public static final String TABLE = "statements";

    /**
     * Dynamo DB table column.
     */
    public static final String KEY_OWNER = "owner";

    /**
     * Dynamo DB table column.
     */
    public static final String KEY_TIME = "time";

    /**
     * Dynamo DB table column.
     */
    private static final String FIELD_DETAILS = "details";

    /**
     * Dynamo DB table column.
     */
    private static final String FIELD_AMOUNT = "amount";

    /**
     * Dynamo DB table column.
     */
    private static final String FIELD_BALANCE = "balance";

    /**
     * Dynamo.
     */
    private final transient Region region;

    /**
     * URN of the user.
     */
    private final transient URN name;

    /**
     * Date to start with.
     */
    private final transient Time head;

    /**
     * Public ctor.
     * @param reg Region in Dynamo
     * @param urn URN of the user
     */
    protected AwsStatements(final Region reg, final URN urn) {
        this(reg, urn, new Time());
    }

    /**
     * Public ctor.
     * @param reg Region in Dynamo
     * @param urn URN of the user
     * @param time Date to start with
     */
    protected AwsStatements(final Region reg, final URN urn, final Time time) {
        this.region = reg;
        this.name = urn;
        this.head = time;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Statements tail(final Time time) {
        return new AwsStatements(this.region, this.name, time);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Iterator<Statement> iterator() {
        assert this.head != null;
        final Iterator<Item> items = this.region.table(AwsStatements.TABLE)
            .frame()
            .where(AwsStatements.KEY_OWNER, Conditions.equalTo(this.name))
            .through(new QueryValve().withScanIndexForward(false))
            .iterator();
        // @checkstyle AnonInnerLength (50 lines)
        return new Iterator<Statement>() {
            @Override
            public boolean hasNext() {
                return items.hasNext();
            }
            @Override
            public Statement next() {
                final Item item = items.next();
                return new Statement.Simple(
                    new Time(
                        item.get(AwsStatements.KEY_TIME).getS()
                    ),
                    new Dollars(
                        Long.parseLong(
                            item.get(AwsStatements.FIELD_AMOUNT).getN()
                        )
                    ),
                    new Dollars(
                        Long.parseLong(
                            item.get(AwsStatements.FIELD_BALANCE).getN()
                        )
                    ),
                    item.get(AwsStatements.FIELD_DETAILS).getS()
                );
            }
            @Override
            public void remove() {
                throw new UnsupportedOperationException();
            }
        };
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void add(final Statement statement) {
        final Iterator<Statement> stmts = this.iterator();
        final long balance;
        if (stmts.hasNext()) {
            balance = this.iterator().next().balance().points();
        } else {
            balance = 0L;
        }
        this.region.table(AwsStatements.TABLE).put(
            new Attributes()
                .with(AwsStatements.KEY_OWNER, this.name)
                .with(AwsStatements.KEY_TIME, statement.date())
                .with(AwsStatements.FIELD_DETAILS, statement.details())
                .with(
                    AwsStatements.FIELD_AMOUNT,
                    new AttributeValue().withN(
                        Long.toString(statement.amount().points())
                    )
                )
                .with(
                    AwsStatements.FIELD_BALANCE,
                    new AttributeValue().withN(
                        Long.toString(balance + statement.amount().points())
                    )
                )
        );
    }

}