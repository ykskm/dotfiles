/*
var PLUGIN_INFO =
<VimperatorPlugin>
    <name>{NAME}</name>
    <description>ページ内の単語による入力補完を可能にします。</description>
    <version>0.1</version>
    <author mail="ykskm9@gmail.com">ykskm</author>
    <license></license>
    <detail><![CDATA[
        === 概要 ===
        コマンド入力時にページ内の単語による補完を可能にします。
        候補になる単語は原則としてスペースで区切られた英単語のみで、日本語には対応していません。

        === 準備 ===
        .vimperatorrcに次の設定を書きます。
        >||
        autocmd LocationChange .* :js plugins.cmpl_with_content.clear();
        ||<

        === 使い方 ===
        コマンドの補完候補生成に、 plugins.cmpl_with_content.getCompletions() を使います。
        例えば、次のようなコマンドを作成すると、 mr alc の第3引数をページ内の単語で補完できます。
        >||
        commands.addUserCommand(
            ["alc"],
            "mr alc",
            function (args) {
                liberator.execute("mr alc " + args[0]);
            },
            {
                completer: function(context, args) {
                    context.completions = liberator.plugins.cmpl_with_content.getCompletions();
                }
            },
            true
        );
        ||<

        === 注意 ===
        LocationChangeの後、はじめてgetCompletionsが呼び出された際に補完候補の生成を行います。
        生成の際にはそのページのDOMツリー全体をトラバースするため、
        ページによっては非常に時間がかかる場合があります。
    ]]></detail>
</VimperatorPlugin>;
*/

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


liberator.plugins.cmpl_with_content = {
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

//liberator.log(liberator.plugins.cmpl_with_content.getCompletions(), -1);

})();

