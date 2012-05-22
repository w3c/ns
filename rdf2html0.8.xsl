<?xml version="1.0" encoding="utf-8" ?>
<!--
	# (c) 2011-2012 Andrea Perego
	# License: http://www.gnu.org/licenses/gpl
-->
<xsl:transform
    xmlns:xsl     = "http://www.w3.org/1999/XSL/Transform"
    xmlns:xsd     = "http://www.w3.org/2001/XMLSchema"
    xmlns:rdf     = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs    = "http://www.w3.org/2000/01/rdf-schema#"
    xmlns:owl     = "http://www.w3.org/2002/07/owl#"
    xmlns:dcterms = "http://purl.org/dc/terms/"
    xmlns:foaf    = "http://xmlns.com/foaf/0.1/"
    xmlns:sioc    = "http://rdfs.org/sioc/ns#"
    xmlns:schema  = "http://schema.org/"
    xmlns:cc      = "http://creativecommons.org/ns#"
    xmlns:skos    = "http://www.w3.org/2004/02/skos/core#"
    xmlns:dcat    = "http://www.w3.org/ns/dcat#"
    xmlns:xhv     = "http://www.w3.org/1999/xhtml/vocab#"
    xmlns:xh      = "http://www.w3.org/1999/xhtml"
    xmlns:vann    = "http://purl.org/vocab/vann/"
    xmlns:adms    = "http://www.example.org/ns/adms#"
    xmlns:wdrs    = "http://www.w3.org/2007/05/powder-s#"
  	version="1.0">

  <xsl:output method="html"
              doctype-public="html"
              indent="yes" />

  <xsl:param name="l">
    <xsl:text>en</xsl:text>
  </xsl:param>

  <xsl:template name="substring-after-last">
    <xsl:param name="string" />
    <xsl:param name="delimiter" />
    <xsl:choose>
      <xsl:when test="contains($string, $delimiter)">
        <xsl:call-template name="substring-after-last">
          <xsl:with-param name="string" select="substring-after($string, $delimiter)" />
          <xsl:with-param name="delimiter" select="$delimiter" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>  

  <xsl:template name="local-name-from-expanded-name">
    <xsl:param name="string" />
    <xsl:choose>
      <xsl:when test="contains($string, '#')">
        <xsl:value-of select="substring-after($string, '#')"/>
      </xsl:when>
      <xsl:when test="contains($string, '/')">
        <xsl:call-template name="substring-after-last">
          <xsl:with-param name="string" select="$string"/>
          <xsl:with-param name="delimiter" select="'/'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template> 


  <xsl:template name="class_list">
    <xsl:for-each select="rdf:RDF/owl:Class|rdf:RDF/rdfs:Class|rdf:RDF/rdf:Description">
      <xsl:variable name="useID">
        <xsl:value-of select="translate(rdfs:label, ' ', '')"/>
      </xsl:variable>

      <xsl:variable name="local_name">
        <xsl:call-template name="local-name-from-expanded-name">
          <xsl:with-param name="string" select="@rdf:about" />
        </xsl:call-template>
      </xsl:variable>
    
      <xsl:if test="substring($local_name,1,1) = translate(substring($local_name,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')">
      <li>
        <a href="#{$useID}">
          <var><xsl:value-of select="rdfs:label"/></var>
        </a>
      </li>
      </xsl:if>    
    
    </xsl:for-each>
    
  </xsl:template>

  <xsl:template name="class_definitions">

    <xsl:for-each select="rdf:RDF/owl:Class|rdf:RDF/rdfs:Class|rdf:RDF/rdf:Description">
      <xsl:variable name="useID">
        <xsl:value-of select="translate(rdfs:label, ' ', '')"/>
      </xsl:variable>

      <xsl:variable name="local_name">
        <xsl:call-template name="local-name-from-expanded-name">
          <xsl:with-param name="string" select="@rdf:about" />
        </xsl:call-template>
      </xsl:variable>
    
      <xsl:if test="substring($local_name,1,1) = translate(substring($local_name,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')">
      <h2 id="{$useID}"><xsl:value-of select="rdfs:label"/></h2>
      <table class="term">
      <tbody>
        <tr>
          <th>Type&#xa0;of&#xa0;Term</th>
          <td>Class</td>
        </tr>
        <tr>
          <th>QName</th>
          <td>
            <code><xsl:value-of select="dcterms:identifier"/></code>
          </td>
        </tr>
        <tr>
          <th>URI</th>
          <td>
            <code>
              <xsl:value-of select="@rdf:about"/>
            </code>
          </td>
        </tr>
        <xsl:if test="rdfs:subClassOf">
          <tr>
            <th>Subclass&#xa0;of</th>
            <td><code><xsl:value-of select="rdfs:subClassOf/@rdf:resource"/></code></td>
          </tr>
        </xsl:if>
        
        <tr>
          <th>Definition</th>
          <td>
            <xsl:for-each select="rdfs:comment/child::node()|rdfs:comment/child::text()">
              <xsl:copy-of select="."/>
            </xsl:for-each>
          </td>
        </tr>
        <xsl:if test="vann:usageNote">
          <tr>
            <th>Usage&#xa0;Note</th>
            <td>
              <xsl:for-each select="vann:usageNote/child::node()|vann:usageNote/child::text()">
                <xsl:copy-of select="."/>
              </xsl:for-each>
            </td>
          </tr>
        </xsl:if>
      </tbody>
    </table>

    </xsl:if>    
    
    </xsl:for-each>
    
  </xsl:template>

  <xsl:template name="property_list" >
  
  <xsl:for-each select="rdf:RDF/rdf:Property|rdf:RDF/rdf:Description">

    <xsl:variable name="local_name">
      <xsl:call-template name="local-name-from-expanded-name">
        <xsl:with-param name="string" select="@rdf:about" />
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:if test="substring($local_name,1,1) = translate(substring($local_name,1,1),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')">
    <li>
      <a href="#{dcterms:identifier}">
        <var><xsl:value-of select="rdfs:label"/></var>
      </a>
    </li>
    </xsl:if>
    
    </xsl:for-each>    
    
  </xsl:template>

  <xsl:template name="property_definitions" >
  
  <xsl:for-each select="rdf:RDF/rdf:Property|rdf:RDF/rdf:Description">

    <xsl:variable name="local_name">
      <xsl:call-template name="local-name-from-expanded-name">
        <xsl:with-param name="string" select="@rdf:about" />
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:if test="substring($local_name,1,1) = translate(substring($local_name,1,1),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')">
    <h2 id="{dcterms:identifier}"><xsl:value-of select="rdfs:label"/></h2>
    <table class="term">
      <tbody>
        <tr>
          <th>Type&#xa0;of&#xa0;Term</th>
          <td>Property</td>
        </tr>
        <tr>
          <th>QName</th>
          <td>
            <code><xsl:value-of select="dcterms:identifier"/></code>
          </td>
        </tr>
        <tr>
          <th>URI</th>
          <td>
            <code>
              <xsl:value-of select="@rdf:about"/>
            </code>
          </td>
        </tr>
        <xsl:if test="rdfs:subPropertyOf">
        <tr>
          <th>Subproperty&#xa0;of</th>
          <td><code><xsl:value-of select="rdfs:subPropertyOf/@rdf:resource"/></code></td>
        </tr>
        </xsl:if>
        <tr>
          <th>Definition</th>
          <td>
            <xsl:for-each select="rdfs:comment/child::node()|rdfs:comment/child::text()">
              <xsl:copy-of select="."/>
            </xsl:for-each>
          </td>
        </tr>
        <xsl:if test="vann:usageNote">
          <tr>
            <th>Usage&#xa0;Note</th>
            <td>
            <xsl:for-each select="vann:usageNote/child::node()|vann:usageNote/child::text()">
              <xsl:copy-of select="."/>
            </xsl:for-each>
            </td>
          </tr>
        </xsl:if>
      </tbody>
    </table>

    </xsl:if>
    
    </xsl:for-each>    
    
  </xsl:template>

  <xsl:template match="/">

    <xsl:param name="title" select="rdf:RDF/owl:Ontology/rdfs:label"/>
    <xsl:param name="version" select="rdf:RDF/owl:Ontology/owl:versionInfo"/>
    <xsl:param name="date" select="rdf:RDF/owl:Ontology/dcterms:modified"/>
    <xsl:param name="preferredNamespace" select="rdf:RDF/owl:Ontology/vann:preferredNamespaceUri"/>
    <xsl:param name="preferredPrefix" select="rdf:RDF/owl:Ontology/vann:preferredNamespacePrefix"/>
    <xsl:param name="abstract" select="rdf:RDF/owl:Ontology/dcterms:abstract"/>
    <xsl:param name="documentation" select="rdf:RDF/owl:Ontology/wdrs:describedby/rdf:Description/@rdf:about"/>
    <xsl:param name="uml" select="rdf:RDF/owl:Ontology/foaf:depiction/rdf:Description" />
    <xsl:param name="documentationTitle" select="rdf:RDF/owl:Ontology/wdrs:describedby/rdf:Description/dcterms:title"/>
    <xsl:param name="methodology" select="rdf:RDF/owl:Ontology/dcterms:conformsTo/rdf:Description/@rdf:about"/>
    <xsl:param name="methodologyTitle" select="rdf:RDF/owl:Ontology/dcterms:conformsTo/rdf:Description/dcterms:title"/>
    <xsl:param name="forum" select="rdf:RDF/owl:Ontology/dcterms:relation/sioc:Forum/@rdf:about"/>
    <xsl:param name="forumTitle" select="rdf:RDF/owl:Ontology/dcterms:relation/sioc:Forum/dcterms:title"/>
    <xsl:param name="licence" select="rdf:RDF/owl:Ontology/dcterms:license/rdf:Description/@rdf:about"/>
    <xsl:param name="licenceTitle" select="rdf:RDF/owl:Ontology/dcterms:license/rdf:Description/dcterms:title"/>
    <xsl:param name="thisDocUri" select="concat(translate($preferredNamespace, '#', '/'),translate($date, '-', ''),'/')"/>

    <html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
      <head>
        <meta charset="utf-8" />
        <title>
          <xsl:value-of select="$title" />
        </title>
        <xsl:comment>
          <![CDATA[[if lt IE 9]>
            <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
          <![endif]]]>
       </xsl:comment>

        <meta name="viewport" content="width=device-width" />
        <meta charset="utf-8" />
        <link rel="license" href="{$licence}" />
        <link href="http://www.w3.org/StyleSheets/TR/base.css" rel="stylesheet" type="text/css" title="base W3C /TR styles" />
        <style type="text/css">
          table.term {
            width:100%;
            border-collapse:collapse;
            margin-bottom:2em;
          }
          table.term th, table.term td {
            padding: 0.2em 0.5em;
          }
          table.term th {
            text-align:left;
            padding-left:0;
          }
          table.term tbody th {
            width:8em;
          }
          table.term thead th {
            color: #005A9C;
          }
          section#generator {
            margin:1em 0;
            border-top: 1px solid #999;
          }

          section#generator p {
            text-align:right;
            font-style:italic;
          }
          ul.summaryList {
            list-style-type:none;
            display:block;
            width: 90%;
            margin: 0 auto;
            border: 1px solid black;
            padding: 1em;
            background-color: #ccc;
          }
          ul.summaryList li {
            display:inline-block; 
            margin: 0 0.3em;
            line-height:1.5em;
          }
          figure {
            display:block;
            text-align:center;
          }
          figcaption {
            display:block;
            font-style: italic;
            font-size: smaller;
            font-weight: bold;
            margin:0.5em 0;
          }
        </style>
      </head>
      <body>
        <header id="docHeader">
          <p><a href="/"><img src="/Icons/w3c_home" alt="W3C" height="48" width="72" /></a></p>
          <hgroup>
            <h1 id="docTitle">
              <xsl:value-of select="$title" />
            </h1>
            <h2 id="versionHeader">
              <time datetime="{$date}">
                <xsl:value-of select="$version" />
              </time>
            </h2>
          </hgroup>
          <dl id="versionLinks">
<!--            <dt>This version:</dt>
            <dd>
              <a href="{$thisDocUri}"><xsl:value-of select="$thisDocUri"/></a>
            </dd>
            <dt>Latest version:</dt>
            <dd>
              <a href="{$preferredNamespace}"><xsl:value-of select="$preferredNamespace"/></a>
            </dd>
            <dt>Previous version:</dt>
            <xsl:choose>
              <xsl:when test="rdf:RDF/owl:Ontology/xhv:prev">
            <dd>
              <a href="{rdf:RDF/owl:Ontology/xhv:prev/@rdf:resource}"><xsl:value-of select="rdf:RDF/owl:Ontology/xhv:prev/@rdf:resource"/></a>
            </dd>
              </xsl:when>
              <xsl:otherwise>
            <dd>None</dd>
              </xsl:otherwise>
            </xsl:choose> -->
            <dt>Editor:</dt> 
            <xsl:for-each select="rdf:RDF/owl:Ontology/dcterms:creator">
              <dd>
                <a href="{foaf:homepage/@rdf:resource}"><xsl:value-of select="foaf:name"/></a>
                <xsl:choose>
                  <xsl:when test="schema:affiliation">
                    <xsl:text> </xsl:text><xsl:value-of select="schema:affiliation/foaf:name"/>
                  </xsl:when>
                  <xsl:otherwise>
                    Independent
                  </xsl:otherwise>
                </xsl:choose>
              </dd>
            </xsl:for-each>

          </dl>
        </header>

        <section id="copyright">
          <p><xsl:value-of select="rdf:RDF/owl:Ontology/dcterms:rights"/> This vocabulary is published under the 
            <span xmlns:cc="http://creativecommons.org/ns#" about="{rdf:RDF/owl:Ontology/dcterms:license/rdf:Description/cc:attributionURL/@rdf:resource}"> 
              <a rel="cc:attributionURL" property="cc:attributionName" href="{rdf:RDF/owl:Ontology/dcterms:license/rdf:Description/cc:attributionURL/@rdf:resource}"><xsl:value-of select="rdf:RDF/owl:Ontology/dcterms:license/rdf:Description/cc:attributionName"/></a> / 
              <a rel="license" href="{$licence}"><xsl:value-of select="$licenceTitle"/></a>
            </span>
          </p>
        </section>

        <hr title="Separator for top matter" />

        <section id="abstract">
          <header>
            <h1 >Abstract</h1>
          </header>
          <p><xsl:value-of select="$abstract" /></p>
        </section>

        <section id="status">
          <header>
            <h1>Status of this document</h1>
            <p>
              <em>This section describes the status of this document at the time of its publication. Other documents may supersede it.</em>
            </p>
          </header>

          <p>This document was originally produced by the 
            <a href="{rdf:RDF/owl:Ontology/foaf:maker/foaf:page/@rdf:resource}"><xsl:value-of select="rdf:RDF/owl:Ontology/foaf:maker/foaf:name"/></a>, following the
            <a href="{$methodology}"><xsl:value-of select="$methodologyTitle"/></a>.
          </p>


  <p>This document has been reviewed by representatives of the Member States of the European Union, 
  <abbr title="Public Sector Information">PSI</abbr> publishers, and by other interested parties. 
  Publication of this Final Draft does not imply endorsement by the European Commission or its representatives.
  This is a draft document and may be updated, replaced or made obsolete by other documents at any time. It is inappropriate to cite this
  document as other than work in progress. The Working Group will seek further endorsement by the 
  Member State representatives in the ISA Coordination Group or the Trusted Information Exchange Cluster.</p>

        <p>As of this publication, ADMS is a work item of the W3C <a href="http://www.w3.org/2011/gld/">Government Linked Data Working Group</a>. 
        If you wish to make comments regarding this document, please send them to <a href="mailto:public-gld-comments@w3.org">public-gld-comments@w3.org</a> 
        (<a href="mailto:public-gld-comments-request@w3.org?subject=subscribe">subscribe</a>, 
        <a href="http://lists.w3.org/Archives/Public/public-gld-comments/">archives</a>). 
        All feedback is welcome.</p><p>Publication of this document does not imply endorsement by the 
        <acronym title="World Wide Web Consortium">W3C</acronym> Membership. This is a draft document and may be updated, 
        replaced or obsoleted by other documents at any time. It is inappropriate to cite this document as other than work in progress.</p>
        <p>The GLD Working Group operates under the <a href="http://www.w3.org/Consortium/Patent-Policy-20040205/">5 February 2004 
        <acronym title="World Wide Web Consortium">W3C</acronym> Patent Policy</a>. <acronym title="World Wide Web Consortium">W3C</acronym> 
        maintains a <a href="http://www.w3.org/2004/01/pp-impl/47663/status" rel="disclosure">public list of any patent disclosures</a> made 
        in connection with the deliverables of the group; that page also includes instructions for disclosing a patent. An 
        individual who has actual knowledge of a patent which the individual believes contains 
        <a href="http://www.w3.org/Consortium/Patent-Policy-20040205/#def-essential">Essential Claim(s)</a> must disclose the information in 
        accordance with <a href="http://www.w3.org/Consortium/Patent-Policy-20040205/#sec-Disclosure">section 6 of the 
        <acronym title="World Wide Web Consortium">W3C</acronym> Patent Policy</a>.</p>
        </section>


        <section role="main">
          <header id="toc">
            <h1>Table of Contents</h1>
            <nav>
              <ul>
                <li>
                  <a href="#intro">Introduction</a>
                </li>
                <li>
                  <a href="#namespace">Namespace</a>
                </li>
                <li>
                  <a href="#glance">Vocabulary Terms at a Glance</a>
                </li>
                <li>
                  <a href="#classes">Classes</a>
                </li>
                <li>
                  <a href="#properties">Properties</a>
                </li>
                <li>
                  <a href="#conformance">Conformance Statement</a>
                </li>
              </ul>
            </nav>
          </header>

          <h1 id="intro">Introduction</h1>
          <p><xsl:value-of select="$title" /> was developed under the European 
          Commission's ISA Programme. This is the namespace document, generated
          from the associated RDF schema. Full documentation is provided in the
          <a href="{$documentation}"><xsl:value-of select="$documentationTitle"/></a>
          specification document itself. This includes background information,
          use cases, the conceptual model and full definitions for all terms used.</p>
          
          <h1 id="namespace">Namespace</h1>
          
         
<p>The URI for this vocabulary is</p>
<pre><xsl:value-of select="$preferredNamespace"/></pre>
<p>When abbreviating terms the suggested prefix is <code><xsl:value-of select="$preferredPrefix"/></code></p>
<p>Each class or property in the vocabulary has a URI constructed by appending a term name to the vocabulary URI. For example:</p>
<pre><xsl:value-of select="/rdf:RDF/rdfs:Class/@rdf:about"/></pre>
          <section id="glance">

            <header>
              <h1>Vocabulary Terms at a Glance</h1>
            </header>

          <xsl:for-each select="$uml">
          <section id="umlDiagram">
            <figure>
              <img src="{$uml/@rdf:about}" alt="{$uml/rdfs:label}" />
              <figcaption><xsl:value-of select="$uml/rdfs:label"/></figcaption>
            </figure>
          </section>
          </xsl:for-each>

            <dl>
              <dt>Classes:</dt>
              <dd>
                <ul class="summaryList">
                <xsl:call-template name="class_list"/>
                </ul>
              </dd>
              <dt>Properties:</dt>
              <dd>
                <ul class="summaryList">
                <xsl:call-template name="property_list"/>
                </ul>
              </dd>
            </dl>
          </section>



          <h1 id="classes">Classes</h1>
          <p>This section provides the formal definition of each class in the vocabulary.</p>
          <xsl:call-template name="class_definitions"/>
          <h1 id="properties">Properties</h1>
          <xsl:call-template name="property_definitions"/>
          <h1 id="conformance">Conformance Statement</h1>
          <p>A conformant implementation of this vocabulary MUST understand all vocabulary terms defined in this document.</p>

        </section>

        <section id="generator">
        <p>Document generated from the RDF schema using <a href="rdf2html0.8.xsl">this XSLT</a></p>
        </section>

      </body>
    </html>

  </xsl:template>

</xsl:transform>
