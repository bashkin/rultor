<?xml version="1.0"?>
<!--
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
 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/1999/xhtml" version="2.0" exclude-result-prefixes="xs">
    <xsl:template match="snapshot">
        <xsl:apply-templates select="error"/>
        <xsl:if test="tags/tag">
            <xsl:apply-templates select="tags"/>
        </xsl:if>
        <ul class="list-inline spacious-inline-list">
            <xsl:if test="spec">
                <li class="icon">
                    <i class="icon-beaker" title="show spec"
                        onclick="$(this).closest('div').find('pre.spec').toggle();"><xsl:comment>spec</xsl:comment></i>
                </li>
            </xsl:if>
            <xsl:apply-templates select="version" mode="compact"/>
            <xsl:apply-templates select="work"/>
            <xsl:if test="lines">
                <li>
                    <i class="icon-signal"><xsl:comment>lines</xsl:comment></i>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="lines"/>
                </li>
            </xsl:if>
            <xsl:if test="start and not(finish)">
                <li>
                    <i class="icon-flag-alt"><xsl:comment>start</xsl:comment></i>
                    <xsl:text> </xsl:text>
                    <span class="timeago"><xsl:value-of select="start"/></span>
                </li>
            </xsl:if>
            <xsl:if test="eta">
                <li>
                    <i class="icon-suitcase"><xsl:comment>eta</xsl:comment></i>
                    <xsl:text> </xsl:text>
                    <span class="timeago"><xsl:value-of select="eta"/></span>
                </li>
            </xsl:if>
            <xsl:if test="finish">
                <li>
                    <i class="icon-flag-checkered"><xsl:comment>finish</xsl:comment></i>
                    <xsl:text> </xsl:text>
                    <span class="timeago"><xsl:value-of select="finish"/></span>
                </li>
            </xsl:if>
            <xsl:if test="duration">
                <li>
                    <xsl:call-template name="millis">
                        <xsl:with-param name="millis" select="duration"/>
                    </xsl:call-template>
                </li>
            </xsl:if>
        </ul>
        <xsl:if test="spec">
            <pre style="display:none;" class="spec"><xsl:value-of select="spec"/></pre>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="stdout">
                <div class="progress progress-striped active">
                    <ul class="list-inline pull-right">
                        <li>
                            <small class="icon">
                                <a class="text-danger" title="stop execution immediately">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="stdout"/>
                                        <xsl:text>?interrupt</xsl:text>
                                    </xsl:attribute>
                                    <i class="icon-off"><xsl:comment>off</xsl:comment></i>
                                </a>
                            </small>
                        </li>
                        <li>
                            <small class="icon">
                                <a title="server statistics">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="stdout"/>
                                        <xsl:text>/stats</xsl:text>
                                    </xsl:attribute>
                                    <i class="icon-cloud"><xsl:comment>cloud</xsl:comment></i>
                                </a>
                            </small>
                        </li>
                    </ul>
                    <a title="click to tail the output">
                        <xsl:attribute name="href">
                            <xsl:value-of select="stdout"/>
                        </xsl:attribute>
                        <xsl:call-template name="bar">
                            <xsl:with-param name="style" select="'progress-bar-info'"/>
                            <xsl:with-param name="snapshot" select="."/>
                        </xsl:call-template>
                    </a>
                </div>
            </xsl:when>
            <xsl:when test="eta">
                <div class="progress" style="margin-bottom: 10px;">
                    <xsl:call-template name="bar">
                        <xsl:with-param name="style" select="'progress-bar-warning'"/>
                        <xsl:with-param name="snapshot" select="."/>
                    </xsl:call-template>
                </div>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="steps/step">
            <ul class="list-unstyled">
                <xsl:apply-templates select="steps/step"/>
            </ul>
        </xsl:if>
    </xsl:template>
    <xsl:template match="error">
        <pre class="text-danger"><xsl:value-of select="."/></pre>
    </xsl:template>
    <xsl:template match="work">
        <li>
            <i class="icon-male">
                <xsl:attribute name="title">
                    <xsl:value-of select="owner"/>
                </xsl:attribute>
                <xsl:comment>signal</xsl:comment>
            </i>
        </li>
        <li class="hidden-phone">
            <xsl:value-of select="rule"/>
        </li>
    </xsl:template>
    <xsl:template match="version" mode="compact">
        <li class="icon">
            <a>
                <xsl:attribute name="href">
                    <xsl:text>https://github.com/rultor/rultor/commit/</xsl:text>
                    <xsl:value-of select="revision"/>
                </xsl:attribute>
                <xsl:attribute name="title">
                    <xsl:value-of select="revision"/>
                </xsl:attribute>
                <i class="icon-github"><xsl:comment>github</xsl:comment></i>
            </a>
        </li>
    </xsl:template>
    <xsl:template match="step">
        <xsl:variable name="left" select="start/@at &lt; 0.5"/>
        <li class="step-item">
            <xsl:attribute name="style">
                <xsl:choose>
                    <xsl:when test="$left">
                        <xsl:text>margin-left:</xsl:text>
                        <xsl:value-of select="100 * start/@at"/>
                        <xsl:text>%;</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>margin-right:</xsl:text>
                        <xsl:value-of select="100 * (1 - start/@at)"/>
                        <xsl:text>%;text-align:right;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:if test="$left">
                <i class="icon-chevron-right"><xsl:comment>start</xsl:comment></i>
            </xsl:if>
            <xsl:if test="finish">
                <span class="step-mark">
                    <xsl:attribute name="style">
                        <xsl:text>width:</xsl:text>
                        <xsl:value-of select="100 * (finish/@at - start/@at)"/>
                        <xsl:text>%;</xsl:text>
                        <xsl:choose>
                            <xsl:when test="$left">
                                <xsl:text>left:0;</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>right:0;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:comment>mark</xsl:comment>
                </span>
            </xsl:if>
            <span class="step">
                <xsl:if test="exception">
                    <i class="text-danger icon-warning-sign icon"
                        onclick="$(this).parent().parent().next().toggle();">
                        <xsl:attribute name="title">
                            <xsl:value-of select="exception/class"/>
                        </xsl:attribute>
                        <xsl:comment>exception</xsl:comment>
                    </i>
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:variable name="title">
                    <xsl:value-of select="summary"/>
                    <xsl:if test="exception">
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="exception/cause"/>
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                </xsl:variable>
                <span>
                    <xsl:attribute name="class">
                        <xsl:text>markdown </xsl:text>
                        <xsl:choose>
                            <xsl:when test="level = 'INFO'">
                                <xsl:text>text-success</xsl:text>
                            </xsl:when>
                            <xsl:when test="level = 'WARNING'">
                                <xsl:text>text-warning</xsl:text>
                            </xsl:when>
                            <xsl:when test="level = 'SEVERE'">
                                <xsl:text>text-danger</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>text-muted</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="string-length($title) &gt; 150">
                            <xsl:value-of select="substring($title,1,150)"/>
                            <xsl:text>&#8230;</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$title"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
                <xsl:if test="duration">
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="millis">
                        <xsl:with-param name="millis" select="duration"/>
                    </xsl:call-template>
                </xsl:if>
            </span>
            <xsl:if test="not($left)">
                <i class="icon-chevron-left"><xsl:comment>start</xsl:comment></i>
            </xsl:if>
        </li>
        <xsl:if test="exception/stacktrace">
            <li style="display:none">
                <pre class="text-danger text-left exception"><xsl:value-of select="exception/stacktrace"/></pre>
            </li>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tags">
        <ul class="list-inline spacious-inline-list">
            <xsl:if test="tag/markdown">
                <li class="icon">
                    <i class="icon-plus-sign"
                        onclick="$(this).closest('.panel').find('.detailed').toggle();"><xsl:comment>show</xsl:comment></i>
                </li>
            </xsl:if>
            <xsl:apply-templates select="tag"/>
            <xsl:if test="updated">
                <li class="text-muted">
                    <xsl:text>updated </xsl:text>
                    <span class="timeago"><xsl:value-of select="updated"/></span>
                </li>
            </xsl:if>
        </ul>
        <xsl:if test="tag/markdown">
            <ul class="detailed list-unstyled tag-detailed-list" style="display: none;">
                <xsl:apply-templates select="tag[markdown]" mode="detailed"/>
            </ul>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tag">
        <li>
            <xsl:choose>
                <xsl:when test="level">
                    <xsl:call-template name="tag-label">
                        <xsl:with-param name="tag" select="." />
                        <xsl:with-param name="level" select="level" />
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="tag-label">
                        <xsl:with-param name="tag" select="." />
                        <xsl:with-param name="level" select="'default'" />
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>
    <xsl:template match="tag" mode="detailed">
        <li>
            <ul class="list-inline">
                <li>
                    <xsl:call-template name="tag-label">
                        <xsl:with-param name="tag" select="." />
                        <xsl:with-param name="level" select="'default'" />
                    </xsl:call-template>
                </li>
                <li>
                    <span class="markdown"><xsl:value-of select="markdown"/></span>
                </li>
            </ul>
        </li>
    </xsl:template>
    <xsl:template name="tag-label">
        <xsl:param name="tag"/>
        <xsl:param name="level" as="xs:string"/>
        <xsl:variable name="class">
            <xsl:text>label </xsl:text>
            <xsl:text> </xsl:text>
            <xsl:choose>
                <xsl:when test="$level = 'FINE'">
                    <xsl:text>label-success</xsl:text>
                </xsl:when>
                <xsl:when test="$level = 'INFO'">
                    <xsl:text>label-info</xsl:text>
                </xsl:when>
                <xsl:when test="$level = 'WARNING'">
                    <xsl:text>label-warning</xsl:text>
                </xsl:when>
                <xsl:when test="$level = 'SEVERE'">
                    <xsl:text>label-danger</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>label-default</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$tag/links/link[@rel='filter']">
                <a>
                    <xsl:attribute name="class">
                        <xsl:value-of select="$class"/>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="$tag/links/link[@rel='filter']/@href"/>
                    </xsl:attribute>
                    <xsl:value-of select="$tag/label"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <span>
                    <xsl:attribute name="class">
                        <xsl:value-of select="$class"/>
                    </xsl:attribute>
                    <xsl:value-of select="$tag/label"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="bar">
        <xsl:param name="snapshot"/>
        <xsl:param name="style"/>
        <div>
            <xsl:attribute name="class">
                <xsl:text>progress-bar </xsl:text>
                <xsl:value-of select="$style"/>
            </xsl:attribute>
            <xsl:attribute name="style">
                <xsl:text>width:</xsl:text>
                <xsl:choose>
                    <xsl:when test="$snapshot/eta and updated">
                        <xsl:value-of select="updated/@at * 100"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>50</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>%;</xsl:text>
            </xsl:attribute>
            <!-- this is for W3C compliance -->
            <xsl:text> </xsl:text>
        </div>
    </xsl:template>
    <xsl:template name="ISO-to-milliseconds">
        <xsl:param name="iso" as="xs:string"/>
        <xsl:value-of select="$iso"/>
    </xsl:template>
</xsl:stylesheet>
