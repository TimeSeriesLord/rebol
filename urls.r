REBOL [
    Purpose: {
        Get Everything from a URL
    }
    Note: {
        I saw this script on REBOL.org: 
            http://www.rebol.org/view-script.r?script=url-handler.r
        
        but the code seemed crazy-long for REBOL or too confusing for my liking
    }
    History: [
    ]
    Details: [
        Title:   none
    	Creation:    none
        Name:    none
	    Version: 1.0 
	    File:   %url-parse.r
	    Home:  http://none
	     Programmer:  "Time Series Lord"
	     Rights:  "Copyright (c)  2016"
    ] 
    Tests: [
    
        http://agora-dev.org//forums//archive//subsarch/index.php?site
        http://agora-dev.org//forums/archive/index.php?site
        http://agora-dev.org//forums/index.php?site    
        http://agora-dev.org/forums/archive//subarch/index.php?site
        http://agora-dev.org//forums//archive//subarch/index.php?site
        http://agora-dev.org//forums/archive/index.php?site
        http://agora-dev.org//forums/index.php?site
        http://agora-dev.org/forums/index.php?site
        http://a.b.c.d.subby.dommy.toppy/archive/some/path/to/file/file.html?zz=b&hj=d&e=5&f=a%20b&sid=5&nothing=&re=bol#s3
        http://www.rebol.com/docs/core23/rebolcore-10.html#section-2
        http://www.rebol.com/
        http://rebol.com/
        http://rebol.com
    ]
]

comment {
        
        for the agoura style URLS, gather a block of words that have //
        later, after building the path, go and find the words and fix it
        
        it's hacky but...

}

url-parse: func [
    "Returns a URL object"
    url [url!] "URL"
    /local protocol rest file 
    cgi lag 
][

    ;; return object
    urlo: make object! [
        up: top: 
        cgi: anchor: 
        subdomain: subdomains: domain: tld: 
        dir-path: directories: 
        protocol: file: url: none
    ]
    
    ;; full url as given
    urlo/url: :url 
    
    ;; split the url into the end point and path
    url: split-path url
    
    ;; get the protocol and the rest for further processing
    parse url/1 [copy protocol to "://" 3 skip copy rest to end]
    
    ;; protocol
    urlo/protocol: to-word protocol
    
    ;; up start
    either none? rest [
        urlo/up: to-url rejoin [urlo/protocol "://"  dirize url/2  ]    
    ][
        urlo/up: to-url url/1
    ]
    
    ;; top url
    urlo/top: to-url rejoin [urlo/protocol "://"  dirize third parse urlo/up  "/"]    
    
    ;; if it was only an end point url, i.e., parse copied nothing into rest 
    ;; then trigger the nothing flag
    if nothing: none? rest [rest: url/2]
    
    ;; for these style URLS, gather a block of words that have //
    slashy: copy []
    parse rest [some [thru "//" copy w to "/" (append slashy w) ]]
    
    ;; break up the rest, which is the directory tree    
    rest: parse rest "/"
    
    ;; clean up rest if it has empty ""
    forall rest [if empty? rest/1 [remove rest]]

    ;; subdirectories, only if there (nothing sets above)
    if not nothing [
        urlo/directories: copy []
        sd: copy next rest 
        
        ;; if there are double slash directories
        either not empty? slashy [
            forall sd [
                ;; if it is in the slash mini db
                either found? find slashy sd/1 [
                    ;; insert sd/1 "/"
                    poke sd 1 to-refinement sd/1
                ][change sd to-word sd/1]
            ]
            urlo/dir-path: to-path sd
            forall sd [ append urlo/directories sd/1] 
        ][
            forall sd [ change sd to-word sd/1] 
            urlo/dir-path: to-path sd
            forall sd [ append urlo/directories dirize to-file sd/1] 
        ]
    ]
    
    ;; get all of the domain stuff
    rest: parse rest/1 "."
    
    ;; get the top-level domain
    ;; parse last rest/1 [copy tld to slash to end]
    urlo/tld: last rest

    ;; get the domain
    urlo/domain: pick rest -1 + length? rest
    
    ;; get the subdomains
    ;; junky if  2 < length? rest [ subdom: first at rest -2 + length? rest ]
    if  2 < length? rest [ 
        urlo/subdomains: copy/part rest -2 + length? rest 
        ;; get the actual subdomain 
        urlo/subdomain: last urlo/subdomains
    ]
    
    ;; get the file and if there, the cgi stuff or anchor
    ;; proceed if not a slash at end or not a tld at end
    ;; 3 < length? last parse url/2 ".
    if all [
        not-equal? slash last url/2 
        not-equal? urlo/tld last parse url/2 "."
    ][
        parse url/2 [
            [
                [
                    copy file  [ to "?" | to "#" ] marker: skip copy lag to end 
                ] 
                | copy file to end
            ] 
        ]
        if not empty? lag [
            any [
                ;; if RVC thinks it's CGI
                if not empty? cgi: attempt [decode-cgi lag][urlo/cgi: cgi]
                
                ;; if it is "?site"
                if all [
                    equal? #"?" first marker
                    equal? lag second parse marker to-string first marker
                ][
                    urlo/cgi: lag
                ]
            ]
            
            ;; if it isn't cgi, it must be an anchor
            if none? urlo/cgi [
                urlo/anchor: lag
            ]
        ]
        
        ;; file name set
        urlo/file: file
    ] 
    
    ;; REBOL always returns something
    return urlo

] 

