var wiio = {};

wiio.get_leaf = function(id, entityType, prefix) {
    var el = document.getElementById(id);
    if (!el) {
        alert("Internal inconsistency");
        return false;
    }
    var value = el.value;
    alert(value+" "+entityType+" "+prefix);
    if (entityType == "meta") {
        document.location.href = prefix + value + "/";
    } else {
        document.location.href = prefix + value + "[]?output=gif";
    }
}
