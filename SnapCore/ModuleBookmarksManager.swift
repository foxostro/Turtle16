//
//  ModuleBookmarksManager.swift
//  Simulator
//
//  Created by Andrew Fox on 10/11/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public class ModuleBookmarksManager: NSObject {
    let kBookmarksKey = "com.foxostro.SnapCore.bookmarks"
    var bookmarks: [URL : Data] = [:]
    
    public var bookmarksPath: URL! {
        let appDataPath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first
        let path = appDataPath!.appending("bookmarks.dict")
        return URL.init(fileURLWithPath: path)
    }
    
    public func grantAccess(url: URL?) throws {
        guard let url = url else {
            return
        }
        if let data = bookmarks[url] {
            var isStale = false
            let decodedUrl = try URL.init(resolvingBookmarkData: data, options: NSURL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            _ = decodedUrl.startAccessingSecurityScopedResource()
            return
        }
        let openPanel = NSOpenPanel()
        openPanel.title = "Grant access"
        openPanel.message = "Grant access to modules directory"
        openPanel.prompt = "Grant access"
        openPanel.directoryURL = url
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        let result = openPanel.runModal()
        if result == NSApplication.ModalResponse.OK {
            if let url = openPanel.url {
                let data = try url.bookmarkData(options: NSURL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                bookmarks[url] = data
                let bookmarksData = try NSKeyedArchiver.archivedData(withRootObject: bookmarks, requiringSecureCoding: true)
                UserDefaults.standard.setValue(bookmarksData, forKey: kBookmarksKey)
            }
        }
    }

    public func restoreBookmarks() throws {
        freeBookmarks()
        let maybeBookmarksData = UserDefaults.standard.object(forKey: kBookmarksKey) as? Data
        if let bookmarksData = maybeBookmarksData {
            bookmarks = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self, NSURL.self], from: bookmarksData) as! [URL: Data]
            for bookmark in bookmarks {
                var isStale = false
                let url = try URL.init(resolvingBookmarkData: bookmark.value, options: NSURL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                _ = url.startAccessingSecurityScopedResource()
            }
        }
    }
    
    public func freeBookmarks() {
        for (url, _) in bookmarks {
            url.stopAccessingSecurityScopedResource()
        }
        bookmarks = [:]
    }
    
    deinit {
        freeBookmarks()
    }
}
