(function() {

var WordDict = function() {
    this.dict = {};
};

WordDict.prototype = {
    add: function(word) {
        if (!(word in this.dict)) {
            this.dict[word] = 0;
        }
    },

    addText: function(text) {
        var self = this;
        var p = /[a-zA-Z\_\-]{3,}/g;
        text.split(/[\n\r\s]+/).forEach(function(token) {
            var word;
            while ((matched = p.exec(token)) != null) {
                self.add(matched[0]);
            }
        });
    },

    getCompletions: function() {
        var res = [];
        for (var word in this.dict) {
            res.push([word]);
        }
        return res;
    }
};


var TreeTraverser = function(root) {
    this.root = root;
    this.node = root;
    this.down = true;
}

TreeTraverser.prototype = {
    getFirstChild: function(node) { /* abstract */ },
    getNextSibling: function(node) { /* abstract */ },
    getParent: function(node) { /* abstract */ },

    next: function() {
        if (this.down) {
            var n = this.getFirstChild(this.node);
            if (n) {
                this.node = n;
            } else {
                this.down = false;
            }
        } else {
            var n = this.getNextSibling(this.node);
            if (n) {
                this.node = n;
                this.down = true;
            } else {
                this.node = this.getParent(this.node);
                this.down = false;
            }
        }
    },

    skipDescendant: function() {
        this.down = false;
    }
};


var NodeTraverser = function() {
    TreeTraverser.apply(this, arguments);
}
NodeTraverser.prototype = new TreeTraverser;

NodeTraverser.prototype.getFirstChild = function(node) { return node.firstChild; }
NodeTraverser.prototype.getNextSibling = function(node) { return node.nextSibling; }
NodeTraverser.prototype.getParent = function(node) { return node.parentNode; }


var FrameTraverser = function() {
    TreeTraverser.apply(this, arguments);
}
FrameTraverser.prototype = new TreeTraverser;

FrameTraverser.prototype.getFirstChild = function(node) { return node.frames[0]; }
FrameTraverser.prototype.getNextSibling = function(node) {
    var parent = node.parent;
    var len = parent.frames.length;
    for (var i = 0; i < len; i++) {
        if (parent.frames[i] == node) {
            return parent.frames[++i];
        }
    }
}
FrameTraverser.prototype.getParent = function(node) { return node.parent; }


liberator.plugins._cmpl_by_content = {
    clear: function() {
        this.dict = null;
    },

    createDict: function() {
        function processFrame(frame, dict) {
            if (!("body" in frame.document)) {
                // skip non html document
                return;
            }

            var trav = new NodeTraverser(frame.document.body);
            while (true) {
                trav.next();
                var node = trav.node;
                if (trav.down) {
                    if (node.nodeType == 1) {
                        switch (node.tagName.toLowerCase()) {
                        case "script":
                        case "style":
                            trav.skipDescendant();
                            break;
                        }
                        continue;
                    }
                } else {
                    if (node == trav.root) {
                        break;
                    }
                    if (node.nodeType == 3) {
                        dict.addText(node.textContent);
                    }
                }
            }
        }

        this.clear();
        this.dict = new WordDict();
        var start = new Date();
        var trav = new FrameTraverser(content.window);
        while (true) {
            trav.next();
            var frame = trav.node;
            if (!trav.down) {
                processFrame(frame, this.dict);
                if (frame == trav.root) {
                    break;
                }
            }
        }

        liberator.log("Update WordDict: " + (new Date() - start) + " ms", -1);
    },

    getCompletions: function() {
        if (!this.dict) {
            this.createDict();
        }
        return this.dict.getCompletions();
    }
};

//liberator.log(liberator.plugins._cmpl_by_content.getCompletions(), -1);

})();

