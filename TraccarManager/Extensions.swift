//
// Copyright 2016 William Pearse (w.pearse@gmail.com)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

extension String {
    
    // authored by https://gist.github.com/cemolcay and taken from https://gist.github.com/stevenschobert/540dd33e828461916c11 on 8 May 2016
    var camelCasedString: String {
        let source = self
        if source.characters.contains(" ") {
            let first = source.substring(to: source.characters.index(source.startIndex, offsetBy: 1))
            let cammel = NSString(format: "%@", (source as NSString).capitalized.replacingOccurrences(of: " ", with: "", options: [], range: nil)) as String
            let rest = String(cammel.characters.dropFirst())
            return "\(first)\(rest)"
        } else {
            let first = (source as NSString).lowercased.substring(to: source.characters.index(source.startIndex, offsetBy: 1))
            let rest = String(source.characters.dropFirst())
            return "\(first)\(rest)"
        }
    }
    
}
