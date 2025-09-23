#!/usr/bin/env python3
"""
Script to remove duplicate coordinates from polygon data in flutter_svg_data.json
"""

import json
import os
from typing import List, Dict, Any, Tuple

def distance_between_points(p1: Dict[str, float], p2: Dict[str, float]) -> float:
    """Calculate Euclidean distance between two points."""
    x1, y1 = p1.get('x', 0), p1.get('y', 0)
    x2, y2 = p2.get('x', 0), p2.get('y', 0)
    return ((x2 - x1) ** 2 + (y2 - y1) ** 2) ** 0.5

def remove_duplicate_coordinates(polygon: List[Dict[str, float]], tolerance: float = 1.0) -> List[Dict[str, float]]:
    """
    Remove duplicate and near-duplicate coordinates from a polygon.
    
    Args:
        polygon: List of coordinate dictionaries with 'x' and 'y' keys
        tolerance: Minimum distance between points to consider them different
        
    Returns:
        Cleaned polygon with duplicates removed
    """
    if not polygon or len(polygon) <= 2:
        return polygon
    
    cleaned = [polygon[0]]  # Always keep the first point
    
    for i in range(1, len(polygon)):
        current_point = polygon[i]
        
        # Check if current point is too close to any existing point
        is_duplicate = False
        for existing_point in cleaned:
            if distance_between_points(current_point, existing_point) < tolerance:
                is_duplicate = True
                break
        
        if not is_duplicate:
            cleaned.append(current_point)
    
    # If we have at least 3 points, check if the last point is too close to the first
    if len(cleaned) >= 3:
        if distance_between_points(cleaned[-1], cleaned[0]) < tolerance:
            cleaned.pop()  # Remove the last point if it's too close to the first
    
    return cleaned

def process_json_data(data: Dict[str, Any], tolerance: float = 1.0) -> Tuple[Dict[str, Any], int]:
    """
    Recursively process JSON data to remove duplicate coordinates.
    
    Args:
        data: JSON data dictionary
        tolerance: Minimum distance between points to consider them different
        
    Returns:
        Tuple of (processed_data, total_duplicates_removed)
    """
    total_removed = 0
    
    if isinstance(data, dict):
        for key, value in data.items():
            if key == "polygon" and isinstance(value, list):
                # This is a polygon array, clean it
                original_length = len(value)
                cleaned_polygon = remove_duplicate_coordinates(value, tolerance)
                data[key] = cleaned_polygon
                removed = original_length - len(cleaned_polygon)
                total_removed += removed
                
                if removed > 0:
                    print(f"  Removed {removed} duplicate points from polygon (was {original_length}, now {len(cleaned_polygon)})")
            
            elif isinstance(value, (dict, list)):
                # Recursively process nested structures
                processed_value, nested_removed = process_json_data(value, tolerance)
                data[key] = processed_value
                total_removed += nested_removed
    
    elif isinstance(data, list):
        for i, item in enumerate(data):
            if isinstance(item, (dict, list)):
                processed_item, nested_removed = process_json_data(item, tolerance)
                data[i] = processed_item
                total_removed += nested_removed
    
    return data, total_removed

def main():
    """Main function to process the flutter_svg_data.json file."""
    
    # File paths
    input_file = "assets/output_json/flutter_svg_data.json"
    backup_file = "assets/output_json/flutter_svg_data_backup.json"
    
    # Check if input file exists
    if not os.path.exists(input_file):
        print(f"Error: Input file '{input_file}' not found!")
        print("Make sure you're running this script from the project root directory.")
        return
    
    print("Starting duplicate coordinate removal process...")
    print(f"Input file: {input_file}")
    
    # Load the JSON data
    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        print("✓ JSON file loaded successfully")
    except Exception as e:
        print(f"Error loading JSON file: {e}")
        return
    
    # Create backup
    try:
        with open(backup_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"✓ Backup created: {backup_file}")
    except Exception as e:
        print(f"Warning: Could not create backup: {e}")
    
    # Process the data
    print("\nProcessing polygons...")
    tolerance = 1.0  # Minimum distance between points (adjust as needed)
    processed_data, total_removed = process_json_data(data, tolerance)
    
    # Save the cleaned data
    try:
        with open(input_file, 'w', encoding='utf-8') as f:
            json.dump(processed_data, f, indent=2, ensure_ascii=False)
        print(f"✓ Cleaned data saved to {input_file}")
    except Exception as e:
        print(f"Error saving cleaned data: {e}")
        return
    
    print(f"\n🎉 Process completed!")
    print(f"Total duplicate coordinates removed: {total_removed}")
    print(f"Tolerance used: {tolerance} pixels")
    
    if total_removed > 0:
        print(f"\nOriginal file backed up as: {backup_file}")
        print("The cleaned file should now have better performance and fewer rendering issues.")
    else:
        print("\nNo duplicates found - your file was already clean!")

if __name__ == "__main__":
    main()
