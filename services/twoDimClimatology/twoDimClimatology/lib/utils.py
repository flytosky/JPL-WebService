import re, urllib, os
from urllib2 import urlopen
from StringIO import StringIO
from lxml.etree import XMLParser, parse, tostring


def validateDirectory(dir, mode=0755, noExceptionRaise=False):
    """Validate that a directory can be written to by the current process and return 1.
    Otherwise, try to create it.  If successful, return 1.  Otherwise return None.
    """

    if os.path.isdir(dir):
        if os.access(dir, 7): return 1
        else: return None
    else:
        try:
            os.makedirs(dir, mode)
            os.chmod(dir, mode)
        except:
            if noExceptionRaise: pass
            else: raise
        return 1

def getXmlEtree(xml):
    """Return a tuple of [lxml etree element, prefix->namespace dict].
    """

    parser = XMLParser(remove_blank_text=True)
    if xml.startswith('<?xml') or xml.startswith('<'):
        return (parse(StringIO(xml), parser).getroot(),
                getNamespacePrefixDict(xml))
    else:
        if os.path.isfile(xml): xmlStr = open(xml).read()
        else: xmlStr = urlopen(xml).read()
        return (parse(StringIO(xmlStr), parser).getroot(),
                getNamespacePrefixDict(xmlStr))

def getNamespacePrefixDict(xmlString):
    """Take an xml string and return a dict of namespace prefixes to
    namespaces mapping."""
    
    nss = {} 
    defCnt = 0
    matches = re.findall(r'\s+xmlns:?(\w*?)\s*=\s*[\'"](.*?)[\'"]', xmlString)
    for match in matches:
        prefix = match[0]; ns = match[1]
        if prefix == '':
            defCnt += 1
            prefix = '_' * defCnt
        nss[prefix] = ns
    return nss

def xpath(elt, xp, ns, default=None):
    """
    Run an xpath on an element and return the first result.  If no results
    were returned then return the default value.
    """
    
    res = elt.xpath(xp, namespaces=ns)
    if len(res) == 0: return default
    else: return res[0]
    
def pprintXml(et):
    """Return pretty printed string of xml element."""
    
    return tostring(et, pretty_print=True)
