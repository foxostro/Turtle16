//
//  SandboxAccessManager.swift
//  TurtleCore
//
//  Created by Andrew Fox on 4/13/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa

public protocol SandboxAccessManager {
    func requestAccess(url: URL?)
}

public class ConcreteSandboxAccessManager: SandboxAccessManager {
    let kBookmarksKey = "bookmarks"
    var bookmarks: [URL: Data] = [:]

    deinit {
        for (url, _) in bookmarks {
            url.stopAccessingSecurityScopedResource()
        }
    }

    public init() {
        do {
            let maybeBookmarksData = UserDefaults.standard.object(forKey: kBookmarksKey) as? Data
            if let bookmarksData = maybeBookmarksData {
                bookmarks = try NSKeyedUnarchiver.unarchivedObject(
                    ofClasses: [NSDictionary.self, NSURL.self, NSData.self],
                    from: bookmarksData
                ) as! [URL: Data]
                for bookmark in bookmarks {
                    var isStale = false
                    let url = try URL(
                        resolvingBookmarkData: bookmark.value,
                        options: NSURL.BookmarkResolutionOptions.withSecurityScope,
                        relativeTo: nil,
                        bookmarkDataIsStale: &isStale
                    )
                    _ = url.startAccessingSecurityScopedResource()
                }
            }
        }
        catch {
            NSLog("failed to restore bookmarks: \(error)")
        }
    }

    public func requestAccess(url: URL?) {
        if let url {
            do {
                try tryRequestAccess(url: url)
            }
            catch {
                NSLog(
                    "failed to grant the requested access to url\n\turl: \(url)\n\terror: \(error)"
                )
            }
        }
    }

    func tryRequestAccess(url: URL) throws {
        if let data = bookmarks[url] {
            var isStale = false
            let decodedUrl = try URL(
                resolvingBookmarkData: data,
                options: NSURL.BookmarkResolutionOptions.withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            _ = decodedUrl.startAccessingSecurityScopedResource()
            return
        }
        let openPanel = NSOpenPanel()
        openPanel.title = "Grant access"
        openPanel.message = "Grant access"
        openPanel.prompt = "Grant access"
        openPanel.directoryURL = url
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        let result = openPanel.runModal()
        if result == NSApplication.ModalResponse.OK {
            if let url = openPanel.url {
                let data = try url.bookmarkData(
                    options: NSURL.BookmarkCreationOptions.withSecurityScope,
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                )
                bookmarks[url] = data
                let bookmarksData = try NSKeyedArchiver.archivedData(
                    withRootObject: bookmarks,
                    requiringSecureCoding: true
                )
                UserDefaults.standard.setValue(bookmarksData, forKey: kBookmarksKey)
            }
        }
    }
}
