# Python Coding Problems
## LeetCode
### LeetCode 75 Study Plan
#### 1768. Merge Strings Alternately
**Description:** You are given two strings word1 and word2. Merge the strings by adding letters in alternating order, starting with word1. If a string is longer than the other, append the additional letters onto the end of the merged string.

Return the merged string.

```plaintext
Example 1:

Input: word1 = "abc", word2 = "pqr"
Output: "apbqcr"
Explanation: The merged string will be merged as so:
word1:  a   b   c
word2:    p   q   r
merged: a p b q c r

Example 2:

Input: word1 = "ab", word2 = "pqrs"
Output: "apbqrs"
Explanation: Notice that as word2 is longer, "rs" is appended to the end.
word1:  a   b 
word2:    p   q   r   s
merged: a p b q   r   s

Example 3:

Input: word1 = "abcd", word2 = "pq"
Output: "apbqcd"
Explanation: Notice that as word1 is longer, "cd" is appended to the end.
word1:  a   b   c   d
word2:    p   q 
merged: a p b q c   d
```

**Solution:**

```python
class Solution:
    def mergeAlternately(self, word1: str, word2: str) -> str:
        res = ""
        a = len(word1)
        b = len(word2)

        for i in range(max(a, b)):
            if i < a:
                res += word1[i]
            if i < b:
                res += word2[i]
        
        return res
```

**Explanation:**
- This solution merges two strings by alternating their characters.
- We create an empty result string `res` to store our merged output.
- We determine the length of both input words: `a` for `word1` and `b` for `word2`.
- We iterate through a range up to the maximum length between the two words using `max(a, b)`.
- For each position `i`:
  - If `i` is within the bounds of `word1` (i.e., `i < a`), we append the character at position `i` from `word1` to our result.
  - If `i` is within the bounds of `word2` (i.e., `i < b`), we append the character at position `i` from `word2` to our result.
- This approach handles cases where one string is longer than the other by continuing to append characters from the longer string after we've exhausted the shorter string.
- Time Complexity: O(max(m,n)) where m and n are the lengths of the input strings
- Space Complexity: O(m+n) for the result string

#### 1071. Greatest Common Divisor of Strings

For two strings s and t, we say "t divides s" if and only if `s = t + t + t + ... + t + t` (i.e., t is concatenated with itself one or more times).

Given two strings str1 and str2, return the largest string x such that x divides both str1 and str2.

```plaintext
Example 1:

Input: str1 = "ABCABC", str2 = "ABC"
Output: "ABC"

Example 2:

Input: str1 = "ABABAB", str2 = "ABAB"
Output: "AB"

Example 3:

Input: str1 = "LEET", str2 = "CODE"
Output: ""
```

Constraints:

- `1 <= str1.length, str2.length <= 1000`
- `str1 and str2 consist of English uppercase letters.`

**Solution:**

```python
class Solution:
    def gcdOfStrings(self, str1: str, str2: str) -> str:
        if str1 + str2 != str2 + str1:
            return ""
        if len(str1) == len(str2):
            return str1
        if len(str1) > len(str2):
            return self.gcdOfStrings(str1[len(str2):], str2)
        return self.gcdOfStrings(str1, str2[len(str1):])
```

**Explanation:**
**Explanation:**
- This problem asks us to find the largest string that divides both input strings.
- The solution uses principles similar to the Euclidean algorithm for finding the greatest common divisor of numbers.
- First key insight: If string X is a common divisor of strings A and B, then A+B must equal B+A.
  - If this property doesn't hold, we return an empty string immediately.
- The algorithm then follows a recursive approach:
  - If both strings have the same length and are equal, that string is the GCD.
  - If `str1` is longer than `str2`, we remove one copy of `str2` from the beginning of `str1` and recursively find the GCD.
  - If `str2` is longer than `str1`, we remove one copy of `str1` from the beginning of `str2` and recursively find the GCD.
- This recursive approach continues until we find the GCD or determine that no common divisor exists.
- Time Complexity: O(m+n) where m and n are the lengths of the input strings
- Space Complexity: O(min(m,n)) due to the recursive stack

#### 1431. Kids with the Greatest Number of Candies
There are n kids with candies. You are given an integer array candies, where each candies[i] represents the number of candies the ith kid has, and an integer extraCandies, denoting the number of extra candies that you have.

Return a boolean array result of length n, where result[i] is true if, after giving the ith kid all the extraCandies, they will have the greatest number of candies among all the kids, or false otherwise.

Note that multiple kids can have the greatest number of candies.

```plaintext
Example 1:

Input: candies = [2,3,5,1,3], extraCandies = 3
Output: [true,true,true,false,true] 
Explanation: If you give all extraCandies to:
- Kid 1, they will have 2 + 3 = 5 candies, which is the greatest among the kids.
- Kid 2, they will have 3 + 3 = 6 candies, which is the greatest among the kids.
- Kid 3, they will have 5 + 3 = 8 candies, which is the greatest among the kids.
- Kid 4, they will have 1 + 3 = 4 candies, which is not the greatest among the kids.
- Kid 5, they will have 3 + 3 = 6 candies, which is the greatest among the kids.

Example 2:

Input: candies = [4,2,1,1,2], extraCandies = 1
Output: [true,false,false,false,false] 
Explanation: There is only 1 extra candy.
Kid 1 will always have the greatest number of candies, even if a different kid is given the extra candy.

Example 3:

Input: candies = [12,1,12], extraCandies = 10
Output: [true,false,true]
```
 

Constraints:

- `n == candies.length`
- `2 <= n <= 100`
- `1 <= candies[i] <= 100`
- `1 <= extraCandies <= 50~`

**Solution:**
```python
class Solution:
    def kidsWithCandies(self, candies: List[int], extraCandies: int) -> List[bool]:
        max_candies = max(candies)
        return [candy + extraCandies >= max_candies for candy in candies]
```

**Explanation:**
- This problem asks us to determine, for each kid, whether they would have the most candies if given extra candies.
- The solution follows a straightforward approach:
  - First, find the maximum number of candies any kid currently has (`max_candies`).
  - For each kid, check if their current number of candies plus the extra candies would be at least as much as the current maximum.
  - Return a list of boolean values where `True` indicates the kid would have the most candies after receiving extra candies.
- The solution uses a list comprehension for conciseness and readability.
- Time Complexity: O(n) where n is the number of kids (we iterate through the array once)
- Space Complexity: O(n) for the result list
- This approach handles all edge cases in the problem description, including the note that multiple kids can have the greatest number of candies.

### 605. Can Place Flowers

**Description:** You have a long flowerbed in which some of the plots are planted, and some are not. However, flowers cannot be planted in adjacent plots.

Given an integer array flowerbed containing 0's and 1's, where 0 means empty and 1 means not empty, and an integer n, return if n new flowers can be planted in the flowerbed without violating the no-adjacent-flowers rule.

```plaintext
Example 1:
Input: flowerbed = [1,0,0,0,1], n = 1
Output: true

Example 2:
Input: flowerbed = [1,0,0,0,1], n = 2
Output: false
```

Constraints:
- `1 <= flowerbed.length <= 2 * 10^4`
- `flowerbed[i]` is 0 or 1
- There are no two adjacent flowers in `flowerbed`
- `0 <= n <= flowerbed.length`

**Solution:**
```python
class Solution:
    def canPlaceFlowers(self, flowerbed: List[int], n: int) -> bool:
        count = 0
        length = len(flowerbed)
        
        for i in range(length):
            # Check if current plot is empty
            if flowerbed[i] == 0:
                # Check if left and right plots are empty (or out of bounds)
                is_left_empty = (i == 0) or (flowerbed[i - 1] == 0)
                is_right_empty = (i == length - 1) or (flowerbed[i + 1] == 0)
                
                # If both adjacent plots are empty, we can plant a flower
                if is_left_empty and is_right_empty:
                    flowerbed[i] = 1  # Plant a flower
                    count += 1
                    
                    if count >= n:
                        return True
        
        return count >= n
```

**Explanation:**
- This problem asks us to determine if we can plant n flowers in an existing flowerbed without violating the rule that no two flowers can be adjacent.
- The solution uses a greedy approach, where we try to plant flowers as soon as we find a valid spot.
- We iterate through each position in the flowerbed array and for each empty plot (value 0):
  - We check if both its left and right adjacent plots are also empty (or out of bounds).
  - If both adjacent plots are empty, we can plant a flower at the current position.
  - After planting a flower, we increment our counter and check if we've reached our target.
- The check for left and right plots considers edge cases:
  - For leftmost position (i=0), there's no left plot, so we consider it empty.
  - For rightmost position (i=length-1), there's no right plot, so we consider it empty.
- We modify the flowerbed array in-place to keep track of newly planted flowers.
- Time Complexity: O(n) where n is the length of the flowerbed array
- Space Complexity: O(1) as we only use a constant amount of extra space

### 345. Reverse Vowels of a String

**Description:** Given a string s, reverse only all the vowels in the string and return it.

The vowels are 'a', 'e', 'i', 'o', and 'u', and they can appear in both lower and upper cases.

```plaintext
Example 1:
Input: s = "hello"
Output: "holle"

Example 2:
Input: s = "leetcode"
Output: "leotcede"
```

Constraints:
- `1 <= s.length <= 3 * 10^5`
- `s` consists of printable ASCII characters

**Solution:**
```python
class Solution:
    def reverseVowels(self, s: str) -> str:
        vowels = set(['a', 'e', 'i', 'o', 'u', 'A', 'E', 'I', 'O', 'U'])
        s_list = list(s)  # Convert to list for easier character manipulation
        
        left, right = 0, len(s) - 1
        
        while left < right:
            # Find the leftmost vowel
            while left < right and s_list[left] not in vowels:
                left += 1
            
            # Find the rightmost vowel
            while left < right and s_list[right] not in vowels:
                right -= 1
            
            # Swap the vowels
            s_list[left], s_list[right] = s_list[right], s_list[left]
            
            # Move pointers
            left += 1
            right -= 1
        
        return ''.join(s_list)
```

**Explanation:**
- This problem asks us to reverse only the vowels in a string, leaving all other characters in their original positions.
- The solution uses a two-pointer approach:
  - We define a set of vowels (both lowercase and uppercase).
  - We convert the input string to a list for easier character manipulation.
  - We use two pointers, `left` starting from the beginning and `right` starting from the end.
  - We move the left pointer forward until we find a vowel.
  - We move the right pointer backward until we find a vowel.
  - We swap these vowels and continue the process.
  - Finally, we convert the list back to a string and return it.
- This approach efficiently reverses only the vowels while keeping all other characters in place.
- Time Complexity: O(n) where n is the length of the string
- Space Complexity: O(n) for the character list and output string
- The solution correctly handles both lowercase and uppercase vowels as specified in the problem.

That completes the first 5 problems. Would you like me to continue with the next 5 problems from the LeetCode 75 Study Plan?