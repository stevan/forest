
namespace('Forest.Tree.Service.AJAX');

Forest.Tree.Service.AJAX.Client = function (base_url) {
    this.base_url = base_url || 'http://localhost:8080/';

    this.request  = false;
    this.locked   = false;    
    
    // set up the self referant
    this.oid = this.create_oid();
    eval(this.oid + '=this');    
};

Forest.Tree.Service.AJAX.Client.prototype = new Forest.Object ();

// Utilitiy Methods

Forest.Tree.Service.AJAX.Client.prototype.get_XMLHTTP_request = function () {
	var request = false;
    // branch for native XMLHttpRequest object
    if (window.XMLHttpRequest) {
    	try {
			request = new XMLHttpRequest();
        } catch(e) {
			request = false;
        }
    // branch for IE/Windows ActiveX version
    } 
    else if (window.ActiveXObject) {
       	try {
        	request = new ActiveXObject("Msxml2.XMLHTTP");
      	} catch(e) {
        	try {
          		request = new ActiveXObject("Microsoft.XMLHTTP");
        	} catch(e) {
          		request = false;
        	}
		}    
    }
    return request;
}

Forest.Tree.Service.AJAX.Client.prototype.parse_JSON = function (string) {
    try {
        return !(/[^,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t]/.test(
                string.replace(/"(\\.|[^"\\])*"/g, ''))) &&
            eval('(' + string + ')');
    } catch (e) {
        return false;
    }
};

// API Methods

Forest.Tree.Service.AJAX.Client.prototype.load_tree = function (tree_id) {

    var node = document.getElementById(tree_id);
    
    if (node.hasChildNodes()) {
        if (node.style.display == 'none') {
            this.show_tree(node);           
        }
        else {
            this.hide_tree(node);
        }
    }
    else {
        if (this.locked == false) {
            this.request = this.get_XMLHTTP_request();
    
            var self = this;
            this.request.onreadystatechange = function () { self.check_state() };
            
            this.request.open("GET", (this.base_url + '?tree_id=' + tree_id), true);
            this.request.send(""); 
            this.locked = true;              
        }   
    }
}

// Overrideable Methods

Forest.Tree.Service.AJAX.Client.prototype.show_tree = function (node) {
    node.style.display = 'block';    
}

Forest.Tree.Service.AJAX.Client.prototype.hide_tree = function (node) {
    node.style.display = 'none';
}

Forest.Tree.Service.AJAX.Client.prototype.create_html_for_leaf = function (tree) {
    return "<li>" + tree.node + "</li>";
}

Forest.Tree.Service.AJAX.Client.prototype.create_html_for_branch = function (tree) {
    return "<li><a href=\"javascript:void(0);\" onclick=\"" + this.oid + ".load_tree('" + 
            tree.uid + 
            "')\">" + 
            tree.node + 
            "</a></li><ul id='" +
            tree.uid + 
            "'></ul>";
}

// Internal Methods

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
        this.locked = false;
    }
}

Forest.Tree.Service.AJAX.Client.prototype.insert_trees = function (tree) {
    
    var node = document.getElementById(tree.uid);
    var HTML = node.innerHTML;    
    
    for (var i = 0; i < tree.children.length; i++) {
        var child = tree.children[i];
        if (child.is_leaf == 1) {
            HTML += this.create_html_for_leaf(child);            
        }
        else {
            HTML += this.create_html_for_branch(child);        
        }
    }
    
    node.innerHTML = HTML;
}
