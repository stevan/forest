
namespace('Forest.Tree.Service.AJAX');

Forest.Tree.Service.AJAX.Client = function (base_url) {
    this.base_url = base_url || 'http://localhost:8080/';
    this.request  = false;
    
    // set up the self referant
    this.oid = this.create_oid();
    eval(this.oid + '=this');    
};

Forest.Tree.Service.AJAX.Client.prototype = new Forest.Object ();

Forest.Tree.Service.AJAX.Client.prototype.parse_JSON = function (string) {
    try {
        return !(/[^,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t]/.test(
                string.replace(/"(\\.|[^"\\])*"/g, ''))) &&
            eval('(' + string + ')');
    } catch (e) {
        return false;
    }
};

Forest.Tree.Service.AJAX.Client.prototype.load_tree = function (tree_id) {

    var node = document.getElementById(tree_id);
    
    if (node.hasChildNodes()) {
        if (node.style.display == 'none') {
            node.style.display = 'block';            
        }
        else {
            node.style.display = 'none';
        }
    }
    else {
        this.request = new XMLHttpRequest();
    
        var self = this;
        this.request.onreadystatechange = function () { self.check_state() };
            
        this.request.open("GET", (this.base_url + '?tree_id=' + tree_id), true);
        this.request.send("");    
    }
}

Forest.Tree.Service.AJAX.Client.prototype.check_state = function () {
    if (this.request.readyState == 4) {
        if (this.request.status == 200) {
            var json = this.request.responseText;
            var tree = this.parse_JSON(json);
            if (tree.error) {
                alert("loading tree failed:\n- " + tree.error);
            }
            else { 
                this.insert_trees(tree);
            }
        } 
        else {
            alert("There was a problem retrieving the tree:\n" + this.request.statusText);
        }
    }
}

Forest.Tree.Service.AJAX.Client.prototype.insert_trees = function (tree) {
    
    var node = document.getElementById(tree.uid);
    var HTML = node.innerHTML;    
    
    for (var i = 0; i < tree.children.length; i++) {
        var child = tree.children[i];
        if (child.is_leaf == 1) {
            HTML += "<li>" + child.node + "</li>";            
        }
        else {
            HTML += "<li><a href=\"javascript:void(0);\" onclick=\"" + this.oid + ".load_tree('" + 
                    child.uid + 
                    "')\">" + 
                    child.node + 
                    "</a></li><ul id='" +
                    child.uid + 
                    "'></ul>";        
        }
    }
    
    node.innerHTML = HTML;
}
